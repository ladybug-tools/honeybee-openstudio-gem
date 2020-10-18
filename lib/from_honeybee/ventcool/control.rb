# *******************************************************************************
# Honeybee OpenStudio Gem, Copyright (c) 2020, Alliance for Sustainable 
# Energy, LLC, Ladybug Tools LLC and other contributors. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

require 'from_honeybee/model_object'

require 'openstudio'

module FromHoneybee
  class VentilationControl < ModelObject
    attr_reader :errors, :warnings
    @@outdoor_node = nil
    @@program_manager = nil
    @@sensor_count = 1
    @@actuator_count = 1
    @@program_count = 1

    def initialize(hash = {})
      super(hash)
    end

    def defaults
      @@schema[:components][:schemas][:VentilationControlAbridged][:properties]
    end

    def get_outdoor_node(openstudio_model)
      # get the EMS sensor for the outdoor node if it exists or generate it if it doesn't
      if @@outdoor_node.nil?
        out_var = OpenStudio::Model::OutputVariable.new(
          'Site Outdoor Air Drybulb Temperature', openstudio_model)
        out_var.setReportingFrequency('Timestep')
        out_var.setKeyValue('Environment')
        @@outdoor_node = OpenStudio::Model::EnergyManagementSystemSensor.new(
          openstudio_model, out_var)
        @@outdoor_node.setName('Outdoor_Sensor')
      end
      @@outdoor_node
    end

    def get_program_manager(openstudio_model)
      # get the EMS Program Manager for all window opening if it exists or generate it if it doesn't
      if @@program_manager.nil?
        @@program_manager = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(
          openstudio_model)
        @@program_manager.setName('Temperature_Controlled_Window_Opening')
        @@program_manager.setCallingPoint('BeginTimestepBeforePredictor')
      end
      @@program_manager
      end

    def replace_ems_special_characters(ems_variable_name)
      # remove special characters from an name to be used as an EMS variable
      new_name = ems_variable_name.to_s
      new_name.gsub!(/[^A-Za-z]/, '')
      new_name
    end

    def to_openstudio(openstudio_model, parent_zone, vent_opening_surfaces, vent_opening_factors)
      # Get the outdoor temperature sensor and the room air temperature sensor
      out_air_temp = get_outdoor_node(openstudio_model)
      in_var = OpenStudio::Model::OutputVariable.new('Zone Air Temperature', openstudio_model)
      in_var.setReportingFrequency('Timestep')
      zone_name = parent_zone.name
      os_zone_name = 'Indoor'
      unless zone_name.empty?
        os_zone_name = zone_name.get
        in_var.setKeyValue(os_zone_name)
      end
      in_air_temp = OpenStudio::Model::EnergyManagementSystemSensor.new(openstudio_model, in_var)
      in_sensor_name = replace_ems_special_characters(os_zone_name) + '_Sensor' + @@sensor_count.to_s
      @@sensor_count = @@sensor_count + 1
      in_air_temp.setName(in_sensor_name)

      # set up a schedule sensor if there's a schedule specified
      if @hash[:schedule]
        vent_sch = openstudio_model.getScheduleByName(@hash[:schedule])
        unless vent_sch.empty?  # schedule not specified
          sch_var = OpenStudio::Model::OutputVariable.new('Schedule Value', openstudio_model)
          sch_var.setReportingFrequency('Timestep')
          sch_var.setKeyValue(@hash[:schedule])
          sch_sens = OpenStudio::Model::EnergyManagementSystemSensor.new(openstudio_model, sch_var)
          sch_sensor_name = replace_ems_special_characters(os_zone_name) + '_Sensor' + @@sensor_count.to_s
          @@sensor_count = @@sensor_count + 1
          sch_sens.setName(sch_sensor_name)
        end
      end

      # create the actuators for each of the operaable windows
      actuator_names = []
      vent_opening_surfaces.each do |vent_srf|
        window_act = OpenStudio::Model::EnergyManagementSystemActuator.new(
            vent_srf, 'AirFlow Network Window/Door Opening', 'Venting Opening Factor')
        vent_srf_name = vent_srf.name
        unless vent_srf_name.empty?
          act_name = replace_ems_special_characters(vent_srf_name.get) + \
            '_OpenFactor' + @@actuator_count.to_s
            @@actuator_count = @@actuator_count + 1
          window_act.setName(act_name)
          actuator_names << act_name
        end
      end

      # create the first line of the EMS Program to open each window according to the control logic
      logic_statements = []
      # check the minimum indoor tempertaure for ventilation
      min_in = @hash[:min_indoor_temperature]
      if min_in && min_in != defaults[:min_indoor_temperature][:default]
        logic_statements << '(' + in_sensor_name + ' > ' + min_in.to_s + ')'
      end
      # check the maximum indoor tempertaure for ventilation
      max_in = @hash[:max_indoor_temperature]
      if max_in && max_in != defaults[:max_indoor_temperature][:default]
        logic_statements << '(' + in_sensor_name + ' < ' + max_in.to_s + ')'
      end
      # check the minimum outdoor tempertaure for ventilation
      min_out = @hash[:min_outdoor_temperature]
      if min_out && min_out != defaults[:min_outdoor_temperature][:default]
        logic_statements << '(Outdoor_Sensor > ' + min_out.to_s + ')'
      end
      # check the maximum outdoor tempertaure for ventilation
      max_out = @hash[:max_outdoor_temperature]
      if max_out && max_out != defaults[:max_outdoor_temperature][:default]
        logic_statements << '(Outdoor_Sensor < ' + max_out.to_s + ')'
      end
      # check the delta tempertaure for ventilation
      delta_in_out = @hash[:delta_temperature]
      if delta_in_out && delta_in_out != defaults[:delta_temperature][:default]
        logic_statements << '((' + in_sensor_name + ' - Outdoor_Sensor) > ' + delta_in_out.to_s + ')'
      end
      # check the schedule for ventilation
      if sch_sensor_name
        logic_statements << '(' + sch_sensor_name + ' > 0)'
      end
      # create the complete logic statement for opening windows
      if logic_statements.empty?
        complete_logic = 'IF (Outdoor_Sensor < 100)'  # no logic has been provided; always open windows
      else
        complete_logic = 'IF ' + logic_statements.join(' && ')
      end

      # initialize the program and add the complete logic
      ems_program = OpenStudio::Model::EnergyManagementSystemProgram.new(openstudio_model)
      prog_name = replace_ems_special_characters(os_zone_name) + '_WindowOpening' + @@program_count.to_s
      @@program_count = @@program_count + 1
      ems_program.setName(prog_name)
      ems_program.addLine(complete_logic)

      # loop through each of the actuators and open each window
      actuator_names.zip(vent_opening_factors).each do |act_name, open_factor|
        ems_program.addLine('SET ' + act_name + ' = ' + open_factor.to_s)
      end
      # loop through each of the actuators and close each window
      ems_program.addLine('ELSE')
      actuator_names.each do |act_name|
        ems_program.addLine('SET ' + act_name + ' = 0')
      end
      ems_program.addLine('ENDIF')
      
      # add the program object the the global program manager for all window opening
      prog_manager = get_program_manager(openstudio_model)
      prog_manager.addProgram(ems_program)

      ems_program
    end

    end #VentilationControl
end #FromHoneybee
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

require 'honeybee/construction/dynamic'

require 'to_openstudio/model_object'

module Honeybee
  class WindowConstructionDynamicAbridged

    attr_reader :constructions, :schedule

    @@program_manager = nil
    @@sensor_count = 1
    @@actuator_count = 1
    @@program_count = 1
    @@state_count = 1

    def constructions
      # wind constructions representing the dynamic states
      @constructions
    end

    def sub_faces
      # sub faces that have the construction assigned
      @sub_faces
    end

    def replace_ems_special_characters(ems_variable_name)
      # remove special characters from an name to be used as an EMS variable
      new_name = ems_variable_name.to_s
      new_name = new_name.dup  # avoid the case of frozen strings
      new_name.gsub!(/[^A-Za-z]/, '')
      new_name
    end

    def get_program_manager(openstudio_model)
      # get the EMS Program Manager for all window opening if it exists or generate it if it doesn't
      if @@program_manager.nil?
        @@program_manager = OpenStudio::Model::EnergyManagementSystemProgramCallingManager.new(
          openstudio_model)
        @@program_manager.setName('Dynamic_Window_Constructions')
        @@program_manager.setCallingPoint('BeginTimestepBeforePredictor')
      end
      @@program_manager
    end

    def to_openstudio(openstudio_model)
      # perform the initial translation of the constituient constructions to the opensutido model
  
      # create an empty list that will collect the objects with the construciton assinged
      @sub_faces = []

      # write all versions of the window constructions into the model
      @constructions = []
      @hash[:constructions].each do |win_con|
        constr_obj = WindowConstructionAbridged.new(win_con)
        @constructions << constr_obj.to_openstudio(openstudio_model)
      end

      # set up the EMS sensor for the schedule value
      state_sch = openstudio_model.getScheduleByName(@hash[:schedule])
      @sch_sensor_name = replace_ems_special_characters(@hash[:identifier]) + '_Sensor' + @@sensor_count.to_s
      @@sensor_count = @@sensor_count + 1
      unless state_sch.empty?  # schedule not specified
        sch_var = OpenStudio::Model::OutputVariable.new('Schedule Value', openstudio_model)
        sch_var.setReportingFrequency('Timestep')
        sch_var.setKeyValue(@hash[:schedule])
        sch_sens = OpenStudio::Model::EnergyManagementSystemSensor.new(openstudio_model, sch_var)
        sch_sens.setName(@sch_sensor_name)
      end
    end

    def ems_program_to_openstudio(openstudio_model)
      # after adding sub-faces to the hash, write the EMS program that controls the sub-faces

      # create the actuators for each of the dynamic windows
      actuator_names = []
      @sub_faces.each do |dyn_window|
        window_act = OpenStudio::Model::EnergyManagementSystemActuator.new(
          dyn_window, 'Surface', 'Construction State')
        dyn_window_name = dyn_window.name
        unless dyn_window_name.empty?
          act_name = replace_ems_special_characters(dyn_window_name.get) + '_Actuator' + @@actuator_count.to_s
          @@actuator_count = @@actuator_count + 1
          window_act.setName(act_name)
          actuator_names << act_name
        end
      end

      # create the EMS Program to accout for each state according to the control logic
      ems_program = OpenStudio::Model::EnergyManagementSystemProgram.new(openstudio_model)
      prog_name = replace_ems_special_characters(@hash[:identifier]) + '_StateChange' + @@program_count.to_s
      @@program_count = @@program_count + 1
      ems_program.setName(prog_name)

      # add each construction state to the program
      max_state_count = @constructions.length() - 1
      @constructions.each_with_index do |construction, i|
        # determine which conditional operator to use
        cond_op = 'IF'
        if i != 0
          cond_op = 'ELSEIF'
        end
        
        # add the conditional statement
        state_count = i + 1
        if i == max_state_count
          cond_stmt = 'ELSE'
        else
          cond_stmt = cond_op + ' (' + @sch_sensor_name + ' < ' + state_count.to_s + ')'
        end
        ems_program.addLine(cond_stmt)

        # create the construction index variable
        constr_i = OpenStudio::Model::EnergyManagementSystemConstructionIndexVariable.new(
          openstudio_model, construction)
        constr_name = construction.name
        unless constr_name.empty?
          constr_i_name = replace_ems_special_characters(constr_name.get) + '_State' + @@state_count.to_s
          @@state_count = @@state_count + 1
          constr_i.setName(constr_i_name)
        end

        # loop through the actuators and set the appropriate window state
        actuator_names.each do |act_name|
          ems_program.addLine('SET ' + act_name + ' = ' + constr_i_name)
        end
      end
      ems_program.addLine('ENDIF')

      # add the program object the the global program manager for all window opening
      prog_manager = get_program_manager(openstudio_model)
      prog_manager.addProgram(ems_program)
    end

    def self.add_sub_faces_to_window_dynamic_hash(openstudio_model)
      # loop through the model and add relevant sub_faces to the $window_dynamic_hash

      # get the names of the constructions that would be assigned to the geometry
      constr_names = Hash.new
      $window_dynamic_hash.each do |constr_id, constr_obj|
        first_constr = constr_obj.constructions[0]
        first_constr_name_ref = first_constr.name
        unless first_constr_name_ref.empty?
          first_constr_name = first_constr_name_ref.get
          constr_names[first_constr_name] = constr_id
        end
      end

      # loop through the sub-faces and find any that have the construction assigned
      sub_faces = openstudio_model.getSubSurfaces()
      sub_faces.each do |sub_face|
        constr_ref = sub_face.construction
        unless constr_ref.empty?
          constr = constr_ref.get
          constr_name_ref = constr.name
          unless constr_name_ref.empty?
            constr_name = constr_name_ref.get
            unless constr_names[constr_name].nil?
              dyn_constr_name = constr_names[constr_name]
              $window_dynamic_hash[dyn_constr_name].sub_faces << sub_face
            end
          end
        end
      end
    end

  end #WindowConstructionDynamicAbridged
end #Honeybee

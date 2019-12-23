# *******************************************************************************
# Ladybug Tools Energy Model Schema, Copyright (c) 2019, Alliance for Sustainable
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

require 'ladybug/energy_model/model_object'
require 'ladybug/energy_model/extension_simulation_parameter'

require 'json-schema'
require 'json'
require 'openstudio'

module Ladybug
  module EnergyModel
    class SimulationParameter 
      attr_reader :errors, :warnings

      # Read Simulation Parameter JSON from disk
      def self.read_from_disk(file)
        hash = nil
        File.open(File.join(file), 'r') do |f|
          hash = JSON.parse(f.read, symbolize_names: true)
        end

        SimulationParameter.new(hash)
      end

      # Load ModelObject from symbolized hash
      def initialize(hash)
       # initialize class variable @@extension only once
       @@extension = ExtensionSimulationParameter.new
       @@schema = nil
       File.open(@@extension.schema_file) do |f|
        @@schema = JSON.parse(f.read, symbolize_names: true)
       end

       @hash = hash
       @type = @hash[:type]
       raise 'Unknown model type' if @type.nil?
       raise "Incorrect model type for SimulationParameter '#{@type}'" unless @type == 'SimulationParameter'
      end

      # check if the model is valid
      def valid?
        return validation_errors.empty?
      end

      # return detailed model validation errors
      def validation_errors
        JSON::Validator.fully_validate(@@schema, @hash)
      end

      # convert to openstudio model, clears errors and warnings
      def to_openstudio_model(openstudio_model = nil)
        @errors = []
        @warnings = []

        @openstudio_model = if openstudio_model
                              openstudio_model
                            else
                              OpenStudio::Model::Model.new
                            end

        create_openstudio_objects

        @openstudio_model
      end

      def create_openstudio_objects
        if @hash[:simulation_control]
          #Gets or creates new SimulationControl object from the OpenStudio model
          openstudio_simulation_control = @openstudio_model.getSimulationControl
          unless @hash[:simulation_control][:do_zone_sizing].nil?
            openstudio_simulation_control.setDoZoneSizingCalculation(@hash[:simulation_control][:do_zone_sizing])
          else 
            openstudio_simulation_control.setDoZoneSizingCalculation(@@schema[:definitions][:SimulationControl][:properties][:do_zone_sizing][:default])
          end
          unless @hash[:simulation_control][:do_system_sizing].nil?
            openstudio_simulation_control.setDoSystemSizingCalculation(@hash[:simulation_control][:do_system_sizing])
          else
            openstudio_simulation_control.setDoSystemSizingCalculation(@@schema[:definitions][:SimulationControl][:properties][:do_system_sizing][:default])
          end
          unless @hash[:simulation_control][:do_plant_sizing].nil?
            openstudio_simulation_control.setDoPlantSizingCalculation(@hash[:simulation_control][:do_plant_sizing])
          else
            openstudio_simulation_control.setDoPlantSizingCalculation(@@schema[:definitions][:SimulationControl][:properties][:do_plant_sizing][:default])
          end
          unless @hash[:simulation_control][:run_for_run_periods].nil?
            openstudio_simulation_control.setRunSimulationforWeatherFileRunPeriods(@hash[:simulation_control][:run_for_run_periods])
          else
            openstudio_simulation_control.setRunSimulationforWeatherFileRunPeriods(@@schema[:definitions][:SimulationControl][:properties][:run_for_run_periods][:default])
          end
          unless @hash[:simulation_control][:run_for_sizing_periods].nil?
            openstudio_simulation_control.setRunSimulationforSizingPeriods(@hash[:simulation_control][:run_for_sizing_periods])
          else
            openstudio_simulation_control.setRunSimulationforSizingPeriods(@@schema[:definitions][:SimulationControl][:properties][:run_for_sizing_periods][:default])
          end
          #TODO: Check if solar distribution can be added to simulationcontrol in the schema 
          if @hash[:shadow_calculation][:solar_distribution]
            openstudio_simulation_control.setSolarDistribution(@hash[:shadow_calculation][:solar_distribution])
          else
            openstudio_simulation_control.setSolarDistribution(@@schema[:definitions][:ShadowCalculation][:properties][:solar_distribution][:default])
          end
        end
        if @hash[:shadow_calculation]
          openstudio_shadow_calculation = @openstudio_model.getShadowCalculation
          if @hash[:shadow_calculation][:calculation_frequency]
            openstudio_shadow_calculation.setCalculationFrequency(@hash[:shadow_calculation][:calculation_frequency])
          else
            openstudio_shadow_calculation.setCalculationFrequency(@@schema[:definitions][:ShadowCalculation][:properties][:calculation_frequency][:default])
          end
          if @hash[:shadow_calculation][:maximum_figures]
            openstudio_shadow_calculation.setMaximumFiguresInShadowOverlapCalculations(@hash[:shadow_calculation][:maximum_figures])
          else
            openstudio_shadow_calculation.setMaximumFiguresInShadowOverlapCalculations(@@schema[:definitions][:ShadowCalculation][:properties][:maximum_figures][:default])
          end
          if @hash[:shadow_calculation][:calculation_method]
            openstudio_shadow_calculation.setCalculationMethod(@hash[:shadow_calculation][:calculation_method])
          else
            openstudio_shadow_calculation.setCalculationMethod(@@schema[:definitions][:ShadowCalculation][:properties][:calculation_method][:default])
          end
        end
        if @hash[:sizing_parameter]
          openstudio_sizing_parameter = @openstudio_model.getSizingParameters
          if @hash[:sizing_parameter][:heating_factor]
            openstudio_sizing_parameter.setHeatingSizingFactor(@hash[:sizing_parameter][:heating_factor])
          else
            openstudio_sizing_parameter.setHeatingSizingFactor(@@schema[:definitions][:SizingParameter][:properties][:heating_factor][:default])
          end
          if @hash[:sizing_parameter][:cooling_factor]
            openstudio_sizing_parameter.setCoolingSizingFactor(@hash[:sizing_parameter][:cooling_factor])
          else
            openstudio_sizing_parameter.setCoolingSizingFactor(@@schema[:definitions][:SizingParameter][:properties][:cooling_factor][:default])
          end
        end
        if @hash[:output]
          if @hash[:output][:outputs]
            @hash[:output][:outputs].each do |output|
              openstudio_output = OpenStudio::Model::OutputVariable.new(output, @openstudio_model)
              if @hash[:output][:reporting_frequency]
                openstudio_output.setReportingFrequency(@hash[:output][:reporting_frequency])
              else
                openstudio_output.setReportingFrequency(@@schema[:definitions][:SimulationOutput][:properties][:reporting_frequency][:default])
              end
            end
          end
        end
        if @hash[:run_period]
          openstudio_runperiod = @openstudio_model.getRunPeriod
          openstudio_runperiod.setBeginMonth(@hash[:run_period][:start_date][:month])
          openstudio_runperiod.setBeginDayOfMonth(@hash[:run_period][:start_date][:day])
          openstudio_runperiod.setEndMonth(@hash[:run_period][:end_date][:month])
          openstudio_runperiod.setEndDayOfMonth(@hash[:run_period][:end_date][:day])
          if @hash[:run_period][:daylight_savings_time]
            openstudio_daylight_savings = OpenStudio::Model::RunPeriodControlDaylightSavingTime.new(@openstudio_model)
            year_description = openstudio_model.getYearDescription
            start_date = year_description.makeDate(@hash[:run_period][:daylight_savings_time][:start_date][:month], @hash[:run_period][:daylight_savings_time][:start_date][:day])
            openstudio_daylight_savings.setStartDate(start_date)
            end_date = year_description.makeDate(@hash[:run_period][:daylight_savings_time][:end_date][:month], @hash[:run_period][:daylight_savings_time][:end_date][:day])
            openstudio_daylight_savings.setEndDate(end_date)
          end
        end  
        if @hash[:timestep]
          openstudio_timestep = @openstudio_model.getTimestep
          openstudio_timestep.setNumberOfTimestepsPerHour(@hash[:timestep])
        else
          openstudio_timestep.setNumberOfTimestepsPerHour(@@schema[:properties][:timestep][:default])
        end
      end

    end #SimulationParameter
  end #EnergyModel
end #Ladybug

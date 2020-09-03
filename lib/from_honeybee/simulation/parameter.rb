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
require 'from_honeybee/simulation/extension'
require 'from_honeybee/simulation/designday'

require 'openstudio'

module FromHoneybee
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
      if Gem.loaded_specs.has_key?("json-schema")
        return validation_errors.empty?
      else
        return true
      end
    end

    # return detailed model validation errors
    def validation_errors
      if Gem.loaded_specs.has_key?("json-schema")
        require 'json-schema'
        JSON::Validator.fully_validate(@@schema, @hash)
      end
    end

    def defaults
      @@schema[:components][:schemas]
    end

    # convert to openstudio model, clears errors and warnings
    def to_openstudio_model(openstudio_model=nil, log_report=false)
      @errors = []
      @warnings = []

      if log_report
        puts 'Starting SimulationParameter translation from Honeybee to OpenStudio'
      end
      @openstudio_model = if openstudio_model
                            openstudio_model
                          else
                            OpenStudio::Model::Model.new
                          end

      create_openstudio_objects

      if log_report
        puts 'Done with SimulationParameter translation!'
      end

      @openstudio_model
    end

    def create_openstudio_objects
      # get the defaults for each sub-object
      simct_defaults = defaults[:SimulationControl][:properties]
      shdw_defaults = defaults[:ShadowCalculation][:properties]
      siz_defaults = defaults[:SizingParameter][:properties]
      out_defaults = defaults[:SimulationOutput][:properties]
      runper_defaults = defaults[:RunPeriod][:properties]
      simpar_defaults = defaults[:SimulationParameter][:properties]

      # set defaults for the Model's SimulationControl object
      os_sim_control = @openstudio_model.getSimulationControl
      os_sim_control.setDoZoneSizingCalculation(simct_defaults[:do_zone_sizing][:default])
      os_sim_control.setDoSystemSizingCalculation(simct_defaults[:do_system_sizing][:default])
      os_sim_control.setDoPlantSizingCalculation(simct_defaults[:do_plant_sizing][:default])
      os_sim_control.setRunSimulationforWeatherFileRunPeriods(simct_defaults[:run_for_run_periods][:default])
      os_sim_control.setRunSimulationforSizingPeriods(simct_defaults[:run_for_sizing_periods][:default])
      os_sim_control.setSolarDistribution(shdw_defaults[:solar_distribution][:default])

      # override any SimulationControl defaults with lodaded JSON
      if @hash[:simulation_control]
        unless @hash[:simulation_control][:do_zone_sizing].nil?
          os_sim_control.setDoZoneSizingCalculation(@hash[:simulation_control][:do_zone_sizing])
        end
        unless @hash[:simulation_control][:do_system_sizing].nil?
          os_sim_control.setDoSystemSizingCalculation(@hash[:simulation_control][:do_system_sizing])            
        end
        unless @hash[:simulation_control][:do_plant_sizing].nil?
          os_sim_control.setDoPlantSizingCalculation(@hash[:simulation_control][:do_plant_sizing])
        end
        unless @hash[:simulation_control][:run_for_run_periods].nil?
          os_sim_control.setRunSimulationforWeatherFileRunPeriods(@hash[:simulation_control][:run_for_run_periods])
        end
        unless @hash[:simulation_control][:run_for_sizing_periods].nil?
          os_sim_control.setRunSimulationforSizingPeriods(@hash[:simulation_control][:run_for_sizing_periods])
        end
      end

      # set defaults for the Model's ShadowCalculation object
      os_shadow_calc = @openstudio_model.getShadowCalculation
      begin
        os_shadow_calc.setShadingCalculationMethod(
          shdw_defaults[:calculation_method][:default])
      rescue NoMethodError  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
        os_shadow_calc.setCalculationMethod(
          shdw_defaults[:calculation_method][:default])
      end
      begin
        os_shadow_calc.setShadingCalculationUpdateFrequencyMethod(
          shdw_defaults[:calculation_update_method][:default])
      rescue  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
      end
      begin
        os_shadow_calc.setShadingCalculationUpdateFrequency(
          shdw_defaults[:calculation_frequency][:default])
      rescue NoMethodError  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
        os_shadow_calc.setCalculationFrequency(
          shdw_defaults[:calculation_frequency][:default])
      end
      os_shadow_calc.setMaximumFiguresInShadowOverlapCalculations(
        shdw_defaults[:maximum_figures][:default])

      # override any ShadowCalculation defaults with lodaded JSON
      if @hash[:shadow_calculation]
        if @hash[:shadow_calculation][:calculation_method]
          begin
            os_shadow_calc.setShadingCalculationMethod(
              @hash[:shadow_calculation][:calculation_method])
          rescue NoMethodError  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
            os_shadow_calc.setCalculationMethod(
              @hash[:shadow_calculation][:calculation_method])
          end
        end
        if @hash[:shadow_calculation][:calculation_update_method]
          begin
            os_shadow_calc.setShadingCalculationUpdateFrequencyMethod(
              @hash[:shadow_calculation][:calculation_update_method])
          rescue  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
          end
        end
        if @hash[:shadow_calculation][:calculation_frequency]
          begin
            os_shadow_calc.setShadingCalculationUpdateFrequency(
              @hash[:shadow_calculation][:calculation_frequency])
          rescue NoMethodError  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
            os_shadow_calc.setCalculationFrequency(
              @hash[:shadow_calculation][:calculation_frequency])
          end
        end
        if @hash[:shadow_calculation][:maximum_figures]
          os_shadow_calc.setMaximumFiguresInShadowOverlapCalculations(
            @hash[:shadow_calculation][:maximum_figures])
        end
        if @hash[:shadow_calculation][:solar_distribution]
          os_sim_control.setSolarDistribution(
            @hash[:shadow_calculation][:solar_distribution])
        end
      end
      
      # set defaults for the Model's SizingParameter object
      os_sizing_par = @openstudio_model.getSizingParameters
      os_sizing_par.setHeatingSizingFactor(siz_defaults[:heating_factor][:default])
      os_sizing_par.setCoolingSizingFactor(siz_defaults[:cooling_factor][:default])

      # override any SizingParameter defaults with lodaded JSON
      if @hash[:sizing_parameter]
        if @hash[:sizing_parameter][:heating_factor]
          os_sizing_par.setHeatingSizingFactor(@hash[:sizing_parameter][:heating_factor])
        end
        if @hash[:sizing_parameter][:cooling_factor]
          os_sizing_par.setCoolingSizingFactor(@hash[:sizing_parameter][:cooling_factor])
        end
        # set any design days
        if @hash[:sizing_parameter][:design_days]
          @hash[:sizing_parameter][:design_days].each do |des_day|
            des_day_object = DesignDay.new(des_day)
            os_des_day = des_day_object.to_openstudio(@openstudio_model)
          end
        end
      end

      # set Outputs for the simulation
      if @hash[:output]
        if @hash[:output][:outputs]
          @hash[:output][:outputs].each do |output|
            os_output = OpenStudio::Model::OutputVariable.new(output, @openstudio_model)
            if @hash[:output][:reporting_frequency]
              os_output.setReportingFrequency(@hash[:output][:reporting_frequency])
            else
              os_output.setReportingFrequency(out_defaults[:reporting_frequency][:default])
            end
          end
        end
        if @hash[:output][:summary_reports]
          begin
            os_report = @openstudio_model.getOutputTableSummaryReports
          rescue  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
          end
          @hash[:output][:summary_reports].each do |report|
            begin
              os_report.addSummaryReport(report)
            rescue NoMethodError  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
            end
          end
        end
      end

      # set defaults for the year description
      year_description = @openstudio_model.getYearDescription
      year_description.setDayofWeekforStartDay(runper_defaults[:start_day_of_week][:default])

      # set up the simulation RunPeriod
      if @hash[:run_period]
        # set the leap year
        if @hash[:run_period][:leap_year]
          year_description.setIsLeapYear(@hash[:run_period][:leap_year])
        end

        # set the start day of the week
        if @hash[:run_period][:start_day_of_week]
          year_description.setDayofWeekforStartDay(@hash[:run_period][:start_day_of_week])
        end

        # set the run preiod start and end dates
        openstudio_runperiod = @openstudio_model.getRunPeriod
        openstudio_runperiod.setBeginMonth(@hash[:run_period][:start_date][0])
        openstudio_runperiod.setBeginDayOfMonth(@hash[:run_period][:start_date][1])
        openstudio_runperiod.setEndMonth(@hash[:run_period][:end_date][0])
        openstudio_runperiod.setEndDayOfMonth(@hash[:run_period][:end_date][1])

        # set the daylight savings time
        if @hash[:run_period][:daylight_saving_time]
          os_dl_saving = @openstudio_model.getRunPeriodControlDaylightSavingTime
          os_dl_saving.setStartDate(
            OpenStudio::MonthOfYear.new(@hash[:run_period][:daylight_saving_time][:start_date][0]),
            @hash[:run_period][:daylight_saving_time][:start_date][1])
          os_dl_saving.setEndDate(
            OpenStudio::MonthOfYear.new(@hash[:run_period][:daylight_saving_time][:end_date][0]),
            @hash[:run_period][:daylight_saving_time][:end_date][1])
        end

        # Set the holidays
        if @hash[:run_period][:holidays]
          @hash[:run_period][:holidays].each do |hol|
            begin
              os_hol = OpenStudio::Model::RunPeriodControlSpecialDays.new(
                OpenStudio::MonthOfYear.new(hol[0]), hol[1], @openstudio_model)
              os_hol.setDuration(1)
              os_hol.setSpecialDayType('Holiday')
            rescue NoMethodError  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
            end
          end
        end
      end

      # set the simulation timestep
      os_timestep = @openstudio_model.getTimestep
      if @hash[:timestep]
        os_timestep.setNumberOfTimestepsPerHour(@hash[:timestep])
      else
        os_timestep.setNumberOfTimestepsPerHour(simpar_defaults[:timestep][:default])
      end

      # assign the north
      if @hash[:north_angle]
        @openstudio_model.getBuilding.setNorthAxis(-@hash[:north_angle])
      end

      # assign the terrain
      os_site = @openstudio_model.getSite
      os_site.setTerrain(simpar_defaults[:terrain_type][:default])
      if @hash[:terrain_type]
        os_site.setTerrain(@hash[:terrain_type])
      end
    end

  end #SimulationParameter
end #FromHoneybee

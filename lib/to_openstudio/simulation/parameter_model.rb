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

require 'honeybee/simulation/parameter_model'

require 'openstudio'

module Honeybee
  class SimulationParameter

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
      os_shadow_calc.setShadingCalculationMethod(
        shdw_defaults[:calculation_method][:default])
      os_shadow_calc.setShadingCalculationUpdateFrequencyMethod(
        shdw_defaults[:calculation_update_method][:default])
      os_shadow_calc.setShadingCalculationUpdateFrequency(
        shdw_defaults[:calculation_frequency][:default])
      os_shadow_calc.setMaximumFiguresInShadowOverlapCalculations(
        shdw_defaults[:maximum_figures][:default])

      # override any ShadowCalculation defaults with lodaded JSON
      if @hash[:shadow_calculation]
        if @hash[:shadow_calculation][:calculation_method]
          os_shadow_calc.setShadingCalculationMethod(
            @hash[:shadow_calculation][:calculation_method])
        end
        if @hash[:shadow_calculation][:calculation_update_method]
          os_shadow_calc.setShadingCalculationUpdateFrequencyMethod(
            @hash[:shadow_calculation][:calculation_update_method])
        end
        if @hash[:shadow_calculation][:calculation_frequency]
          os_shadow_calc.setShadingCalculationUpdateFrequency(
            @hash[:shadow_calculation][:calculation_frequency])
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
      db_temps = []
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
            db_temps << des_day[:dry_bulb_condition][:dry_bulb_max]
          end
        end
      end

      # use the average of design day temperatures to set the water mains temperature
      os_water_mains = @openstudio_model.getSiteWaterMainsTemperature
      os_version_water_fix = OpenStudio::VersionString.new(3, 4)
      if @openstudio_model.version() >= os_version_water_fix
        os_water_mains.setCalculationMethod('CorrelationFromWeatherFile')
      else
        os_water_mains.setCalculationMethod('Correlation')
        if db_temps.length > 0
          os_water_mains.setAnnualAverageOutdoorAirTemperature((db_temps.max + db_temps.min) / 2)
        else  # just use some dummy values so that the simulation does not fail
          os_water_mains.setAnnualAverageOutdoorAirTemperature(12)
        end
        os_water_mains.setMaximumDifferenceInMonthlyAverageOutdoorAirTemperatures(4)
      end

      # set the climate zone from design days assuming 0.4% extremes and normal distribution
      climate_zone_objs = @openstudio_model.getClimateZones
      ashrae_zones = climate_zone_objs.getClimateZones('ASHRAE')
      if ashrae_zones.empty? && db_temps.length > 0
        # generate temperatures according to a normal distribution
        mean_temp = (db_temps.max + db_temps.min) / 2
        dist_to_mean = db_temps.max - mean_temp
        st_dev = dist_to_mean / 2.65
        vals = []
        for i in 0..4379
          step_seed = i.to_f / 4380
          add_val1, add_val2 = gaussian(mean_temp, st_dev, step_seed)
          vals << add_val1
          vals << add_val2
        end

        # compute the number of heating and cooling degree days
        cooling_deg_days, heating_deg_days = 0, 0
        vals.each do |temp|
          if temp > 10
            cdd = (temp - 10) / 24
            cooling_deg_days += cdd
          end
          if temp < 18
            hdd = (18 - temp) / 24
            heating_deg_days += hdd
          end
        end

        # determine the climate zone from the degree-day distribution
        if cooling_deg_days > 5000
          cz = '1'
        elsif cooling_deg_days > 3500
          cz = '2A'
        elsif cooling_deg_days > 2500
          cz = '3A'
        elsif cooling_deg_days <= 2500 and heating_deg_days <= 2000
          cz = '3C'
        elsif cooling_deg_days <= 2500 and heating_deg_days <= 3000
          cz = '4A'
        elsif heating_deg_days <= 3000
          cz = '4C'
        elsif heating_deg_days <= 4000
          cz = '5A'
        elsif heating_deg_days <= 5000
          cz = '6A'
        elsif heating_deg_days <= 7000
          cz = '7'
        else
            cz = '8'
        end

        # set the climate zone
        climate_zone_objs.setClimateZone('ASHRAE', cz)
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
          os_report = @openstudio_model.getOutputTableSummaryReports
          @hash[:output][:summary_reports].each do |report|
            os_report.addSummaryReport(report)
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
            os_hol = OpenStudio::Model::RunPeriodControlSpecialDays.new(
              OpenStudio::MonthOfYear.new(hol[0]), hol[1], @openstudio_model)
            os_hol.setDuration(1)
            os_hol.setSpecialDayType('Holiday')
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
        @openstudio_model.getBuilding.setNorthAxis(@hash[:north_angle])
      end

      # assign the terrain
      os_site = @openstudio_model.getSite
      os_site.setTerrain(simpar_defaults[:terrain_type][:default])
      if @hash[:terrain_type]
        os_site.setTerrain(@hash[:terrain_type])
      end

    end

    def gaussian(mean, stddev, seed)
      # generate a gaussian distribution of values
      theta = 2 * Math::PI * seed
      rho = Math.sqrt(-2 * Math.log(1 - seed))
      scale = stddev * rho
      x = mean + scale * Math.cos(theta)
      y = mean + scale * Math.sin(theta)
      return x, y
    end

  end #SimulationParameter
end #Honeybee

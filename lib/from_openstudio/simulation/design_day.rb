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

require 'honeybee/model_object'

module Honeybee
  class DesignDay

    def self.from_design_day(design_day)
      hash = {}
      hash[:type] = 'DesignDay'
      hash[:name] = design_day.nameString
      hash[:day_type] = day_type_from_design_day(design_day)
      hash[:dry_bulb_condition] = dry_bulb_condition_from_design_day(design_day)
      hash[:humidity_condition] = humidity_condition_from_design_day(design_day)
      hash[:wind_condition] = wind_condition_from_design_day(design_day)
      hash[:sky_condition] = sky_condition_from_design_day(design_day)

      hash
    end

    def self.day_type_from_design_day(design_day)
      design_day.dayType
    end

    def self.dry_bulb_condition_from_design_day(design_day)
      hash = {}
      hash[:type] = 'DryBulbCondition'
      hash[:dry_bulb_max] = design_day.maximumDryBulbTemperature
      hash[:dry_bulb_range] = design_day.dailyDryBulbTemperatureRange
      hash
    end

    def self.humidity_type_from_design_day(design_day)
      humidity_type = design_day.humidityIndicatingType
      allowed_types = ['WetBulb', 'Dewpoint', 'HumidityRatio', 'Enthalpy']
      if !allowed_types.any?{ |s| s.casecmp(humidity_type)==0 }
        raise "'#{humidity_type}' is not an allowed humidity type"
      end
      humidity_type.gsub('WetBulb', 'Wetbulb')
    end

    def self.humidity_condition_from_design_day(design_day)
      hash = {}
      hash[:type] = 'HumidityCondition'
      hash[:humidity_type] = humidity_type_from_design_day(design_day)
      hash[:humidity_value] = design_day.humidityIndicatingConditionsAtMaximumDryBulb
      hash[:barometric_pressure] = design_day.barometricPressure
      hash[:rain] = design_day.rainIndicator
      hash[:snow_on_ground] = design_day.snowIndicator
      hash
    end

    def self.wind_condition_from_design_day(design_day)
      hash = {}
      hash[:type] = 'WindCondition'
      hash[:wind_speed] = design_day.windSpeed
      hash[:wind_direction] = design_day.windDirection
      hash
    end

    def self.ashrae_clear_sky_from_design_day(design_day)
      hash = {}
      hash[:type] = 'ASHRAEClearSky'
      hash[:date] = [design_day.month, design_day.dayOfMonth]
      hash[:clearness] = design_day.skyClearness
      hash[:daylight_savings] = design_day.daylightSavingTimeIndicator
      hash
    end

    def self.ashrae_tau_from_design_day(design_day)
      hash = {}
      hash[:type] = 'ASHRAETau'
      hash[:date] = [design_day.month, design_day.dayOfMonth]
      hash[:tau_b] = design_day.ashraeTaub
      hash[:tau_d] = design_day.ashraeTaud
      hash[:daylight_savings] = design_day.daylightSavingTimeIndicator
      hash
    end

    def self.sky_condition_from_design_day(design_day)
      solar_model_indicator = design_day.solarModelIndicator
      allowed_types = ['ASHRAEClearSky', 'ASHRAETau', 'ASHRAETau2017']
      if !allowed_types.any?{ |s| s.casecmp(solar_model_indicator)==0 }
        raise "'#{solar_model_indicator}' is not an allowed solar model indicator"
      end
      if solar_model_indicator == 'ASHRAEClearSky'
        return ashrae_clear_sky_from_design_day(design_day)
      else
        return ashrae_tau_from_design_day(design_day)
      end
    end

  end # DesignDay
end # Honeybee

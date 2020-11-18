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

require 'honeybee/simulation/design_day'

require 'to_openstudio/model_object'

module Honeybee
  class DesignDay

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getDesignDayByName(@hash[:name])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create the DesignDay object
      os_des_day = OpenStudio::Model::DesignDay.new(openstudio_model)
      os_des_day.setName(@hash[:name])
      os_des_day.setDayType(@hash[:day_type])

      # set the DryBulbCondition properties
      os_des_day.setMaximumDryBulbTemperature(@hash[:dry_bulb_condition][:dry_bulb_max])
      os_des_day.setDailyDryBulbTemperatureRange(@hash[:dry_bulb_condition][:dry_bulb_range])

      # set the HumidityCondition properties
      os_des_day.setHumidityIndicatingType(@hash[:humidity_condition][:humidity_type])
      os_des_day.setHumidityIndicatingConditionsAtMaximumDryBulb(@hash[:humidity_condition][:humidity_value])
      if @hash[:humidity_condition][:barometric_pressure]
        os_des_day.setBarometricPressure(@hash[:humidity_condition][:barometric_pressure])
      end
      if @hash[:humidity_condition][:rain]
        os_des_day.setRainIndicator(@hash[:humidity_condition][:rain])
      end
      if @hash[:humidity_condition][:snow_on_ground]
        os_des_day.setSnowIndicator(@hash[:humidity_condition][:snow_on_ground])
      end

      # set the WindCondition properties
      os_des_day.setWindSpeed(@hash[:wind_condition][:wind_speed])
      if @hash[:wind_condition][:wind_direction]
        os_des_day.setWindDirection(@hash[:wind_condition][:wind_direction])
      end

      # set the SkyCondition properties
      os_des_day.setMonth(@hash[:sky_condition][:date][0])
      os_des_day.setDayOfMonth(@hash[:sky_condition][:date][1])
      os_des_day.setSolarModelIndicator(@hash[:sky_condition][:type])
      if @hash[:sky_condition][:daylight_savings]
        os_des_day.setDaylightSavingTimeIndicator(@hash[:sky_condition][:daylight_savings])
      end

      # ASHRAEClearSky SkyCondition
      if @hash[:sky_condition][:type] == "ASHRAEClearSky"
        os_des_day.setSkyClearness(@hash[:sky_condition][:clearness])
      end

      # ASHRAETau SkyCondition
      if @hash[:sky_condition][:type] == "ASHRAETau"
        os_des_day.setAshraeTaub(@hash[:sky_condition][:tau_b])
        os_des_day.setAshraeTaud(@hash[:sky_condition][:tau_d])
      end

      os_des_day
    end
  end # DesignDay
end # Honeybee

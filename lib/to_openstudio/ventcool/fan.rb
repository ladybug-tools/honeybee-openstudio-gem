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

require 'honeybee/ventcool/fan'

require 'to_openstudio/model_object'

module Honeybee
  class VentilationFanAbridged

    def find_existing_openstudio_object(openstudio_model)
      model_zone_vent = openstudio_model.getZoneVentilationDesignFlowRateByName(@hash[:identifier])
      return model_zone_vent.get unless model_zone_vent.empty?
      nil
    end

    def to_openstudio(openstudio_model, parent)
      # create zone ventilation object and set identifier
      os_zone_vent = OpenStudio::Model::ZoneVentilationDesignFlowRate.new(openstudio_model)
      os_zone_vent.setName(@hash[:identifier] + '..' + parent.name.get)
      unless @hash[:display_name].nil?
        os_zone_vent.setDisplayName(@hash[:display_name])
      end

      # assign flow rate
      os_zone_vent.setDesignFlowRate(@hash[:flow_rate])
      os_zone_vent.setFanPressureRise(@hash[:pressure_rise])
      os_zone_vent.setFanTotalEfficiency(@hash[:efficiency])

      # assign the ventilation type if it exists
      if @hash[:ventilation_type]
        os_zone_vent.setVentilationType(@hash[:ventilation_type])
      else
        os_zone_vent.setVentilationType(defaults[:ventilation_type][:default])
      end

      # set all of the ventilation control properties
      vent_control_hash = @hash[:control]
      if vent_control_hash
        # assign min_indoor_temperature
        if vent_control_hash[:min_indoor_temperature]
          os_zone_vent.setMinimumIndoorTemperature(vent_control_hash[:min_indoor_temperature])
        else
          os_zone_vent.setMinimumIndoorTemperature(
            defaults_control[:min_indoor_temperature][:default])
        end
        # assign max_indoor_temperature
        if vent_control_hash[:max_indoor_temperature]
          os_zone_vent.setMaximumIndoorTemperature(vent_control_hash[:max_indoor_temperature])
        else
          os_zone_vent.setMaximumIndoorTemperature(
            defaults_control[:max_indoor_temperature][:default])
        end
        # assign min_outdoor_temperature
        if vent_control_hash[:min_outdoor_temperature]
          os_zone_vent.setMinimumOutdoorTemperature(vent_control_hash[:min_outdoor_temperature])
        else
          os_zone_vent.setMinimumOutdoorTemperature(
            defaults_control[:min_outdoor_temperature][:default])
        end
        # assign max_outdoor_temperature
        if vent_control_hash[:max_outdoor_temperature]
          os_zone_vent.setMaximumOutdoorTemperature(vent_control_hash[:max_outdoor_temperature])
        else
          os_zone_vent.setMaximumOutdoorTemperature(
            defaults_control[:max_outdoor_temperature][:default])
        end
        # assign delta_temperature
        if vent_control_hash[:delta_temperature]
          os_zone_vent.setDeltaTemperature(vent_control_hash[:delta_temperature])
        else
          os_zone_vent.setDeltaTemperature(
            defaults_control[:delta_temperature][:default])
        end
        # assign schedule if it exists
        if vent_control_hash[:schedule]
          vent_sch = openstudio_model.getScheduleByName(vent_control_hash[:schedule])
          unless vent_sch.empty?
            vent_sch_object = vent_sch.get
            os_zone_vent.setOpeningAreaFractionSchedule(vent_sch_object)
          end
        end
      end

      os_zone_vent
    end

  end # VentilationFanAbridged
end # Honeybee
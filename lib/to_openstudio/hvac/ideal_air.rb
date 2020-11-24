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

require 'honeybee/hvac/ideal_air'

require 'to_openstudio/model_object'

module Honeybee
  class IdealAirSystemAbridged

    def to_openstudio(openstudio_model)
      # create the ideal air system and set the identifier
      os_ideal_air = OpenStudio::Model::ZoneHVACIdealLoadsAirSystem.new(openstudio_model)
      os_ideal_air.setName(@hash[:identifier])

      # assign the economizer type
      if @hash[:economizer_type]
        os_ideal_air.setOutdoorAirEconomizerType(@hash[:economizer_type])
      else
        os_ideal_air.setOutdoorAirEconomizerType(
          defaults[:economizer_type][:default])
      end

      # set the sensible heat recovery
      if @hash[:sensible_heat_recovery] != 0
        os_ideal_air.setSensibleHeatRecoveryEffectiveness(@hash[:sensible_heat_recovery])
        os_ideal_air.setHeatRecoveryType('Sensible')
      else
        os_ideal_air.setSensibleHeatRecoveryEffectiveness(
          defaults[:sensible_heat_recovery][:default])
      end

      # set the latent heat recovery
      if @hash[:latent_heat_recovery] != 0
        os_ideal_air.setLatentHeatRecoveryEffectiveness(@hash[:latent_heat_recovery])
        os_ideal_air.setHeatRecoveryType('Enthalpy')
      else
        os_ideal_air.setLatentHeatRecoveryEffectiveness(
          defaults[:latent_heat_recovery][:default])
      end

      # assign the demand controlled ventilation
      if @hash[:demand_controlled_ventilation]
        os_ideal_air.setDemandControlledVentilationType('OccupancySchedule')
      else
        os_ideal_air.setDemandControlledVentilationType('None')
      end

      # set the maximum heating supply air temperature
      if @hash[:heating_air_temperature]
        os_ideal_air.setMaximumHeatingSupplyAirTemperature(@hash[:heating_air_temperature])
      else
        os_ideal_air.setMaximumHeatingSupplyAirTemperature(
          defaults[:heating_air_temperature][:default])
      end

      # set the maximum cooling supply air temperature
      if @hash[:cooling_air_temperature]
        os_ideal_air.setMinimumCoolingSupplyAirTemperature(@hash[:cooling_air_temperature])
      else
        os_ideal_air.setMinimumCoolingSupplyAirTemperature(
          defaults[:cooling_air_temperature][:default])
      end

      # assign limits to the system's heating capacity
      if @hash[:heating_limit] == {:type => 'NoLimit'}
        os_ideal_air.setHeatingLimit('NoLimit')
      else
        os_ideal_air.setHeatingLimit('LimitCapacity')
        if @hash[:heating_limit].is_a? Numeric
          os_ideal_air.setMaximumSensibleHeatingCapacity(@hash[:heating_limit])
        else
          os_ideal_air.autosizeMaximumSensibleHeatingCapacity()
        end
      end

      # assign limits to the system's cooling capacity
      if @hash[:cooling_limit] == {:type => 'NoLimit'}
        os_ideal_air.setCoolingLimit('NoLimit')
      else
        os_ideal_air.setCoolingLimit('LimitFlowRateAndCapacity')
        if @hash[:cooling_limit].is_a? Numeric
          os_ideal_air.setMaximumTotalCoolingCapacity(@hash[:cooling_limit])
          os_ideal_air.autosizeMaximumCoolingAirFlowRate()
        else
          os_ideal_air.autosizeMaximumTotalCoolingCapacity()
          os_ideal_air.autosizeMaximumCoolingAirFlowRate()
        end
      end

      # assign heating availability schedules
      if @hash[:heating_availability]
        schedule = openstudio_model.getScheduleByName(@hash[:heating_availability])
        unless schedule.empty?
          os_schedule = schedule.get
          os_ideal_air.setHeatingAvailabilitySchedule(os_schedule)
        end
      end

      # assign cooling availability schedules
      if @hash[:cooling_availability]
        schedule = openstudio_model.getScheduleByName(@hash[:cooling_availability])
        unless schedule.empty?
          os_schedule = schedule.get
          os_ideal_air.setCoolingAvailabilitySchedule(os_schedule)
        end
      end

      os_ideal_air
    end

  end #IdealAirSystemAbridged
end #Honeybee

# *******************************************************************************
# 4ju0 d/zf OpenStudio Gem, Copyright (c) 2020, Alliance for Sustainable
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

        def self.from_hvac(hvac)
            # create an empty hash
            hash = {}
            hash[:type] = 'IdealAirSystemAbridged'
            hash[:identifier] = clean_name(hvac.nameString)
            unless hvac.displayName.empty?
                hash[:display_name] = (hvac.displayName.get).force_encoding("UTF-8")
            end
            hash[:economizer_type] = hvac.outdoorAirEconomizerType
            if hvac.demandControlledVentilationType.downcase == 'none'
                hash[:demand_controlled_ventilation] = false
            else
                hash[:demand_controlled_ventilation] = true
            end
            hash[:sensible_heat_recovery] = hvac.sensibleHeatRecoveryEffectiveness
            hash[:latent_heat_recovery] = hvac.latentHeatRecoveryEffectiveness
            hash[:heating_air_temperature] = hvac.maximumHeatingSupplyAirTemperature
            hash[:cooling_air_temperature] = hvac.minimumCoolingSupplyAirTemperature
            if hvac.heatingLimit == 'NoLimit'
                hash[:heating_limit] = hvac.heatingLimit
            end
            if hvac.coolingLimit == 'NoLimit'
                hash[:cooling_limit] = hvac.coolingLimit
            end
            unless hvac.heatingAvailabilitySchedule.empty?
                schedule = hvac.heatingAvailabilitySchedule.get
                hash[:heating_availability] = schedule.nameString
            end
            unless hvac.coolingAvailabilitySchedule.empty?
                schedule = hvac.coolingAvailabilitySchedule.get
                hash[:coolingAvailabilitySchedule]
            end
            
            hash
        end

    end #IdealAirSystemAbridged
end #Honeybee

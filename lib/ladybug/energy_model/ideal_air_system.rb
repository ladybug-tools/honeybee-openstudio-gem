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

require 'ladybug/energy_model/extension'
require 'ladybug/energy_model/model_object'

module Ladybug
  module EnergyModel
    class IdealAirSystem < ModelObject
      attr_reader :errors, :warnings
  
      def initialize(hash = {})
        super(hash)
        raise "Incorrect model type '#{@type}'" unless @type == 'IdealAirSystem'
      end
    
      def defaults
        result = {}
        result
      end

      def create_openstudio_object(openstudio_model)       
        openstudio_ideal_air = OpenStudio::Model::ZoneHVACIdealLoadsAirSystem.new(openstudio_model)
        if @hash[:heating_limit]
          openstudio_ideal_air.setHeatingLimit('LimitCapacity')
          if @hash[:heating_limit] == 'autocalculate'
            openstudio_ideal_air.autosizeMaximumSensibleHeatingCapacity()
          elsif 
            openstudio_ideal_air.setMaximumSensibleHeatingCapacity(@hash[:heating_limit])
          end
        end
        if @hash[:cooling_limit]
          openstudio_ideal_air.setCoolingLimit('LimitFlowRateAndCapacity')
          if @hash[:cooling_limit] == 'autocalculate'
            openstudio_ideal_air.autosizeMaximumTotalCoolingCapacity ()
            openstudio_ideal_air.autosizeMaximumCoolingAirFlowRate()
          elsif
            openstudio_ideal_air.setMaximumTotalCoolingCapacity(@hash[:cooling_limit])
            openstudio_ideal_air.autosizeMaximumCoolingAirFlowRate()
          end
        end
        if @hash[:economizer_type]
          openstudio_ideal_air.setOutdoorAirEconomizerType(@hash[:economizer_type])
        else
          openstudio_ideal_air.setOutdoorAirEconomizerType(@@schema[:definitions][:IdealAirSystem][:properties][:economizer_type][:default])
        end
        if @hash[:sensible_heat_recovery]
          openstudio_ideal_air.setSensibleHeatRecoveryEffectiveness(@hash[:sensible_heat_recovery])
        else
          openstudio_ideal_air.setSensibleHeatRecoveryEffectiveness(@@schema[:definitions][:IdealAirSystem][:properties][:sensible_heat_recovery][:default]) #TODO : Openstudio defaults are different from schema
        end
        if @hash[:latent_heat_recovery]
          openstudio_ideal_air.setLatentHeatRecoveryEffectiveness(@hash[:latent_heat_recovery])
        else
          openstudio_ideal_air.setLatentHeatRecoveryEffectiveness(@@schema[:definitions][:IdealAirSystem][:properties][:latent_heat_recovery][:default]) #TODO : Openstudio defaults are different from schema
        end
        if @hash[:demand_control_ventilation]
          if @hash[:demand_control_ventilation] == true
            openstudio_ideal_air.setDemandControlledVentilationType('OccupancySchedule') #TODO: when true, what is demand control vent. type?
          elsif @hash[:demand_control_ventilation] == false
            openstudio_ideal_air.setDemandControlledVentilationType('None')
          end
        else 
          openstudio_ideal_air.setDemandControlledVentilationType('None')
        end
        openstudio_ideal_air
      end

    end #IdealAirSystem
  end #EnergyModel
end #Ladybug        

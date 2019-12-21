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

require "#{File.dirname(__FILE__)}/extension"
require "#{File.dirname(__FILE__)}/model_object"

module Ladybug
  module EnergyModel
    class GasEquipmentAbridged < ModelObject
      attr_reader :errors, :warnings
  
      def initialize(hash = {})
        super(hash)
        raise "Incorrect model type '#{@type}'" unless @type == 'GasEquipmentAbridged'
      end
    
      def defaults
        result = {}
        result
      end
    
      def find_existing_openstudio_object(openstudio_model)
        model_gas_equipment = openstudio_model.getGasEquipmentDefinitionByName(@hash[:name])
        return model_gas_equipment.get unless model_gas_equipment.empty?
        nil
      end
    
      def create_openstudio_object(openstudio_model)
        openstudio_gas_equipment_definition = OpenStudio::Model::GasEquipmentDefinition.new(openstudio_model)
        openstudio_gas_equipment_definition.setWattsperSpaceFloorArea(@hash[:watts_per_area])
        if @hash[:gas_equipment][:radiant_fraction]
          openstudio_gas_equipment_definition.setFractionRadiant(@hash[:radiant_fraction])
        else 
          openstudio_gas_equipment_definition.setFractionRadiant(@@schema[:definitions][:GasEquipmentAbridged][:properties][:radiant_fraction][:default])
        end
        if @hash[:gas_equipment][:latent_fraction]
          openstudio_gas_equipment_definition.setFractionLatent(@hash[:gas_equipment][:latent_fraction])
        else
          openstudio_gas_equipment_definition.setFractionLatent(@@schema[:definitions][:GasEquipmentAbridged][:properties][:latent_fraction][:default])
        end
        if @hash[:gas_equipment][:lost_fraction]
          openstudio_gas_equipment_definition.setFractionLost(@hash[:gas_equipment][:lost_fraction])
        else 
          openstudio_gas_equipment_definition.setFractionLost(@@schema[:definitions][:GasEquipmentAbridged][:properties][:lost_fraction][:default])
        end

        openstudio_gas_equipment = OpenStudio::Model::GasEquipment.new(openstudio_model)
        openstudio_gas_equipment.setName(@hash[:name])
        openstudio_gas_equipment.setGasEquipmentDefinition(openstudio_gas_equipment_definition)

        gas_equipment_schedule = openstudio_model.getScheduleByName(@hash[:gas_equipment][:schedule])
        unless gas_equipment_schedule.empty?
          gas_equipment_schedule_object = gas_equipment_schedule.get
        end
        openstudio_gas_equipment.setSchedule(gas_equipment_schedule_object)

        openstudio_gas_equipment
      end

    end #GasEquipmentAbridged
  end #EnergyModel 
end #Ladybug

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
    class ElectricalEquipmentAbridged < ModelObject
      attr_reader :errors, :warnings
  
      def initialize(hash = {})
        super(hash)
        raise "Incorrect model type '#{@type}'" unless @type == 'ElectricalEquipmentAbridged'
      end
    
      def defaults
        result = {}
        result
      end
    
      def find_existing_openstudio_object(openstudio_model)
        model_electrical_equipment = openstudio_model.getElectricalEquipmentDefinitionByName(@hash[:name])
        return model_electrical_equipment.get unless model_electrical_equipment.empty?
        nil
      end
    
      def create_openstudio_object(openstudio_model)
        openstudio_electric_equipment_definition = OpenStudio::Model::ElectricEquipmentDefinition.new(openstudio_model)
        openstudio_electric_equipment_definition.setWattsperSpaceFloorArea(@hash[:watts_per_area])
        if @hash[:radiant_fraction]
          openstudio_electric_equipment_definition.setFractionRadiant(@hash[:radiant_fraction])
        else 
          openstudio_electric_equipment_definition.setFractionRadiant(@@schema[:definitions][:ElectricalEquipmentAbridged][:properties][:radiant_fraction][:default])
        end
        if @hash[:latent_fraction]
          openstudio_electric_equipment_definition.setFractionLatent(@hash[:latent_fraction])
        else
          openstudio_electric_equipment_definition.setFractionLatent(@@schema[:definitions][:ElectricalEquipmentAbridged][:properties][:latent_fraction][:default])
        end
        if @hash[:lost_fraction]
          openstudio_electric_equipment_definition.setFractionLost(@hash[:lost_fraction])
        else 
          openstudio_electric_equipment_definition.setFractionLatent(@@schema[:definitions][:ElectricalEquipmentAbridged][:properties][:lost_fraction][:default])
        end

        openstudio_electric_equipment = OpenStudio::Model::ElectricEquipment.new(openstudio_model)
        openstudio_electric_equipment.setName(@hash[:name])
        openstudio_electric_equipment.setElectricEquipmentDefinition(openstudio_electric_equipment_definition)

        electric_equipment_schedule_object = nil
        electric_equipment_schedule = openstudio_model.getScheduleByName(@hash[:schedule])
        unless electric_equipment_schedule.empty?
          electric_equipment_schedule_object = electric_equipment_schedule.get
        end
        openstudio_electric_equipment.setSchedule(electric_equipment_schedule_object)

        openstudio_electric_equipment
      end

    end #ElectricalEquipmentAbridged
  end #EnergyModel
end #Ladybug
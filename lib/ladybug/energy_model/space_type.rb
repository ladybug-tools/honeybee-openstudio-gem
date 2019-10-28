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
    class SpaceType < ModelObject
      attr_reader :errors, :warnings
  
      def initialize(hash = {})
        super(hash)
    
        raise "Incorrect model type '#{@type}'" unless @type == 'ProgramTypeAbridged'
      end
    
      def defaults
        result = {}
        result
      end
    
      def find_existing_openstudio_object(openstudio_model)
        model_space_type = openstudio_model.getSpaceTypeByName(@hash[:name])
        return model_space_type.get unless model_space_type.empty?
        nil
      end
    
      def create_openstudio_object(openstudio_model)    
        openstudio_space_type = OpenStudio::Model::SpaceType.new(openstudio_model)
        openstudio_space_type.setName(@hash[:name])

        if @hash[:people]
          openstudio_people_definition = OpenStudio::Model::PeopleDefinition.new(openstudio_model)
          openstudio_people_definition.setName(@hash[:people][:name])
          openstudio_people_definition.setPeopleperSpaceFloorArea(@hash[:people][:people_per_area])
          if @hash[:people][:radiant_fraction]
            openstudio_people_definition.setFractionRadiant(@hash[:people][:radiant_fraction])
          else
            openstudio_people_definition.setFractionRadiant(@@schema[:definitions][:PeopleAbridged][:radiant_fraction][:default])
          end
          #TODO if @hash[:people][:latent_fraction]
          
          openstudio_people = OpenStudio::Model::People.new(openstudio_people_definition)
          openstudio_people.setPeopleDefinition(openstudio_people_definition)
          openstudio_people.setSpaceType(openstudio_space_type)
         
          people_activity_schedule_object = nil
          people_activity_schedule = openstudio_model.getScheduleByName(@hash[:people][:activity_schedule])
          unless people_activity_schedule.empty?
            people_activity_schedule_object = people_activity_schedule.get
          end
          openstudio_people.setActivityLevelSchedule(people_activity_schedule_object)

          people_occupancy_schedule_object = nil
          people_occupancy_schedule = openstudio_model.getScheduleByName(@hash[:people][:occupancy_schedule])
          unless people_occupancy_schedule.empty?
            people_occupancy_schedule_object = people_occupancy_schedule.get
          end
          openstudio_people.setNumberofPeopleSchedule(people_occupancy_schedule_object)
        end

        if @hash[:lighting]
          openstudio_lights_definition = OpenStudio::Model::LightsDefinition.new(openstudio_model)
          openstudio_lights_definition.setName(@hash[:lighting][:name])
          openstudio_lights_definition.setWattsperSpaceFloorArea(@hash[:lighting][:watts_per_area])
          if @hash[:lighting][:visible_fraction]
            openstudio_lights_definition.setFractionVisible(@hash[:lighting][:visible_fraction])
          else
            openstudio_lights_definition.setFractionVisible(@@schema[:definitions][:LightingAbridged][:properties][:visible_fraction][:default])
          end
          if @hash[:lighting][:radiant_fraction]
            openstudio_lights_definition.setFractionRadiant(@hash[:lighting][:radiant_fraction])
          else
            openstudio_lights_definition.setFractionRadiant(@@schema[:definitions][:LightingAbridged][:properties][:radiant_fraction][:default])
          end
          if @hash[:lighting][:return_air_fraction]
            openstudio_lights_definition.setReturnAirFraction(@hash[:lighting][:return_air_fraction])
          else 
            openstudio_lights_definition.setReturnAirFraction(@@schema[:definitions][:LightingAbridged][:properties][:return_air_fraction][:default])
          end
          
          openstudio_lights = OpenStudio::Model::Lights.new(openstudio_lights_definition)
          openstudio_lights.setLightsDefinition(openstudio_lights_definition)
          openstudio_lights.setSpaceType(openstudio_space_type)

          lighting_schedule_object = nil
          lighting_schedule = openstudio_model.getScheduleByName(@hash[:lighting][:schedule])
          unless lighting_schedule.empty?
            lighting_schedule_object = lighting_schedule.get
          end         
          openstudio_lights.setSchedule(lighting_schedule_object)
        end

        if @hash[:electrical_equipment]
          openstudio_electric_equipment_definition = OpenStudio::Model::ElectricEquipmentDefinition.new(openstudio_model)
          openstudio_electric_equipment_definition.setName(@hash[:electrical_equipment][:name])
          openstudio_electric_equipment_definition.setWattsperSpaceFloorArea(@hash[:lighting][:watts_per_area])
          if @hash[:lighting][:radiant_fraction]
            openstudio_electric_equipment_definition.setFractionRadiant(@hash[:electrical_equipment][:radiant_fraction])
          else 
            openstudio_electric_equipment_definition.setFractionRadiant(@@schema[:definitions][:ElectricalEquipmentAbridged][:properties][:radiant_fraction][:default])
          end
          if @hash[:lighting][:latent_fraction]
            openstudio_electric_equipment_definition.setFractionLatent(@hash[:electrical_equipment][:latent_fraction])
          else
            openstudio_lights_definition.setFractionLatent(@@schema[:definitions][:ElectricalEquipmentAbridged][:properties][:latent_fraction][:default])
          end
          if @hash[:lighting][:lost_fraction]
            openstudio_lights_definition.setFractionLost(@hash[:electrical_equipment][:lost_fraction])
          else 
            openstudio_lights_definition.setReturnAirFraction(@@schema[:definitions][:ElectricalEquipmentAbridged][:properties][:lost_fraction][:default])
          end

          openstudio_electric_equipment = OpenStudio::Model::ElectricEquipment.new(openstudio_model)
          openstudio_electric_equipment.setElectricEquipmentDefinition(openstudio_electric_equipment_definition)
          openstudio_electric_equipment.setSpaceType(openstudio_space_type)

          electric_equipment_schedule_object = nil
          electric_equipment_schedule = openstudio_model.getScheduleByName(@hash[:electrical_equipment][:schedule])
          unless electric_equipment_schedule.empty?
            electric_equipment_schedule_object = electric_equipment_schedule.get
          end
          openstudio_electric_equipment.setSchedule(electric_equipment_schedule_object)
        end

        if @hash[:gas_equipment]
         openstudio_gas_equipment_definition = OpenStudio::Model::GasEquipmentDefinition.new(openstudio_model)
         openstudio_gas_equipment_definition.setName(@hash[:gas_equipment][:name])
         openstudio_gas_equipment_definition.setWattsperSpaceFloorArea(@hash[:gas_equipment][:watts_per_area])
         if @hash[:gas_equipment][:radiant_fraction]
           openstudio_gas_equipment_definition.setFractionRadiant(@hash[:gas_equipment][:radiant_fraction])
         else 
           openstudio_gas_equipment_definition.setFractionRadiant(@@schema[:definitions][:GasEquipmentAbridged][:properties][:radiant_fraction][:default])
         end
         if @hash[:gas_equipment][:latent_fraction]
           openstudio_electric_equipment_definition.setFractionLatent(@hash[:gas_equipment][:latent_fraction])
         else
           openstudio_lights_definition.setFractionLatent(@@schema[:definitions][:GasEquipmentAbridged][:properties][:latent_fraction][:default])
         end
         if @hash[:gas_equipment][:lost_fraction]
           openstudio_gas_equipment_definition.setFractionLost(@hash[:gas_equipment][:lost_fraction])
         else 
           openstudio_gas_definition.setReturnAirFraction(@@schema[:definitions][:GasEquipmentAbridged][:properties][:lost_fraction][:default])
         end

         openstudio_gas_equipment = OpenStudio::Model::GasEquipment.new(openstudio_model)
         openstudio_gas_equipment.setGasEquipmentDefinition(openstudio_gas_equipment_definition)
         openstudio_gas_equipment.setSpaceType(openstudio_space_type)

         gas_equipment_schedule_object = nil
         gas_equipment_schedule = openstudio_model.getScheduleByName(@hash[:gas_equipment][:schedule])
         unless gas_equipment_schedule.empty?
           gas_equipment_schedule_object = gas_equipment_schedule.get
         end
         openstudio_gas_equipment.setSchedule(gas_equipment_schedule_object)
        end

        if @hash[:infiltration]
         openstudio_infiltration = OpenStudio::Model::SpaceInfiltrationDesignFlowRate.new(openstudio_model)
         openstudio_infiltration.setName(@hash[:infiltration][:name])
         openstudio_infiltration.setFlowperExteriorSurfaceArea(@hash[:infiltration][:flow_per_exterior_area])
         if @hash[:infiltration][:constant_coefficient]
           openstudio_infiltration.setConstantTermCoefficient(@hash[:infiltration][:constant_coefficient])
         else 
           openstudio_infiltration.setConstantTermCoefficient(@@schema[:definitions][:InfiltrationAbridged][:properties][:constant_coefficient][:default])
         end
         if @hash[:infiltration][:temperature_coefficient]
           openstudio_infiltration.setTemperatureTermCoefficient(@hash[:infiltration][:temperature_coefficient])
         else
           openstudio_infiltration.setTemperatureTermCoefficient(@@schema[:definitions][:InfiltrationAbridged][:properties][:temperature_coefficient][:default])
         end
         if @hash[:infiltration][:velocity_coefficient]
           openstudio_infiltration.setVelocityTermCoefficient(@hash[:infiltration][:velocity_coefficient])
         else 
           openstudio_infiltration.setVelocityTermCoefficient(@@schema[:definitions][:InfiltrationAbridged][:properties][:velocity_coefficient][:default])
         end
         infiltration_schedule_object = nil
         infiltration_schedule = openstudio_model.getScheduleByName(@hash[:infiltration][:schedule])
         unless infiltration_schedule.empty?
           infiltration_schedule_object = infiltration_schedule.get
         end
         openstudio_infiltration.setSchedule(infiltration_schedule_object)
        end
      
        if @hash[:ventilation]
         openstudio_ventilation = OpenStudio::Model::DesignSpecificationOutdoorAir.new(openstudio_model)
         openstudio_ventilation.setName(@hash[:ventilation][:name])
         if @hash[:ventilation][:air_changes_per_hour]
           openstudio_ventilation.setOutdoorAirFlowAirChangesperHour(@hash[:ventilation][:air_changes_per_hour])
         else
           openstudio_ventilation.setOutdoorAirFlowAirChangesperHour(@@schema[:definitions][:VentilationAbridged][:properties][:air_changes_per_hour][:default])
         end
         #TODO if @hash[:ventilation][:flow_per_zone]
         if @hash[:ventilation][:flow_per_person]
           openstudio_ventilation.setOutdoorAirFlowperPerson(@hash[:ventilation][:flow_per_person])
         else 
           openstudio_ventilation.setOutdoorAirFlowperPerson(@@schema[:definitions][:VentilationAbridged][:properties][:flow_per_person][:default])
         end
         if @hash[:ventilation][:flow_per_area]
           openstudio_ventilation.setOutdoorAirFlowperFloorArea(@hash[:ventilation][:flow_per_area])
         else 
           openstudio_ventilation.setOutdoorAirFlowperPerson(@@schema[:definitions][:VentilationAbridged][:properties][:flow_per_area][:default])
         end
        end

        openstudio_thermostat = OpenStudio::Model::ThermostatSetpointDualSetpoint.new(openstudio_model)
        heating_schedule_object = nil
        heating_schedule = openstudio_model.getScheduleByName(@hash[:setpoint][:heating_schedule])
        unless heating_schedule.empty?
          heating_schedule_object = heating_schedule.get
        end
        openstudio_thermostat.setHeatingSetpointTemperatureSchedule(heating_schedule_object)
        
        cooling_schedule_object = nil
        cooling_schedule = openstudio_model.getScheduleByName(@hash[:setpoint][:cooling_schedule])
        unless cooling_schedule.empty?
          cooling_schedule_object = cooling_schedule.get
        end
        openstudio_thermostat.setCoolingSetpointTemperatureSchedule(cooling_schedule_object)

        if @hash[:setpoint][:humidification_schedule] or @hash[:setpoint][:dehumidification_schedule]
          
          openstudio_humidistat = OpenStudio::Model::ZoneControlHumidistat.new(openstudio_model)
         
          if @hash[:setpoint][:humidification_schedule]
            humidification_schedule_object = nil
            humidification_schedule = openstudio_model.getScheduleByName(@hash[:setpoint][:humidification_schedule])
            unless humidification_schedule.empty?
              humidification_schedule_object = humidification_schedule.get
            end
            openstudio_humidistat.setHumidifyingRelativeHumiditySetpointSchedule(humidification_schedule_object)
          end
          
          if @hash[:setpoint][:dehumidification_schedule]
            dehumidification_schedule_object = nil
            dehumidification_schedule = openstudio_model.getScheduleByName(@hash[:setpoint][:dehumidification_schedule])
            unless dehumidification_schedule.empty?
              dehumidification_schedule_object = dehumidification_schedule.get
            end
            openstudio_humidistat.setDehumidifyingRelativeHumiditySetpointSchedule(dehumidification_schedule_object)
          end

        end

        #TODO: check for schedule for room else get spacetype.

      openstudio_space_type
      end

    end #SpaceType 
  end #EnergyModel
end #Ladybug




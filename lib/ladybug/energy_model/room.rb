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

require 'ladybug/energy_model/model_object'
require 'ladybug/energy_model/face'
require 'ladybug/energy_model/people_abridged'
require 'ladybug/energy_model/ideal_air_system'

require 'json-schema'
require 'json'
require 'openstudio'

module Ladybug
  module EnergyModel
    class Room < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)
        raise "Incorrect model type '#{@type}'" unless @type == 'Room'
      end

      def defaults
        result = {}
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        model_space = openstudio_model.getSpaceByName(@hash[:name])
        return model_space.get unless model_space.empty?
        nil 
      end

      def create_openstudio_object(openstudio_model)
        if @hash[:properties][:energy][:construction_set]
          construction_set_name = @hash[:properties][:energy][:construction_set]
          #gets default construction set assigned to room from openstudio_model
          construction_set = openstudio_model.getDefaultConstructionSetByName(construction_set_name)
          unless construction_set.empty?
            default_construction_set = construction_set.get
          end
        end
        
        openstudio_space = OpenStudio::Model::Space.new(openstudio_model)
        openstudio_space.setName(@hash[:name])   
        if default_construction_set
          openstudio_space.setDefaultConstructionSet(default_construction_set) 
        end
        
        #loop through all faces in the hash and create ladybug face object.
        @hash[:faces].each do |face|
          ladybug_face = Face.new(face)
          openstudio_face = ladybug_face.to_openstudio(openstudio_model)
          openstudio_face.setSpace(openstudio_space)
          
          #Check if boundary construction for surface is Adiabatic and no construction is
          #assigned, get default interior
          #surface construction for space and assign construction for interior surface
          #type to surface.
          if face[:boundary_condition][:type] == 'Adiabatic' && !face[:properties][:energy][:construction]
            openstudio_surfaces = openstudio_space.surfaces.each do |surface|
              #get default construction for space
              construction_set_space = openstudio_space.defaultConstructionSet
              unless construction_set_space.empty?
                construction_set_space_object = construction_set_space.get
                default_interior_surface_construction_set = construction_set_space_object.defaultInteriorSurfaceConstructions
                unless default_interior_surface_construction_set.empty?
                  #get default interior surface construction
                  default_interior_surface_construction_set = default_interior_surface_construction_set.get
                  case surface.surfaceType
                  when 'Wall'
                    interior_wall_construction = default_interior_surface_construction_set.wallConstruction
                    unless interior_wall_construction.empty?
                      interior_wall_construction = interior_wall_construction.get
                      #set interior surface construction  
                      surface.setConstruction(interior_wall_construction)
                    end
                  when 'RoofCeiling'
                    interior_roofceiling_construction = default_interior_surface_construction_set.roofCeilingConstruction
                    unless interior_roofceiling_construction.empty?
                      interior_roofceiling_construction = interior_roofceiling_construction.get 
                      surface.setConstruction(interior_roofceiling_construction)
                    end
                  when 'Floor'
                    interior_floor_construction = default_interior_surface_construction_set.floorConstruction
                    unless interior_floor_construction.empty?
                      interior_floor_construction = interior_floor_construction.get
                      surface.setConstruction(interior_floor_construction)
                    end
                  end
                end
              end
            end
          end
        end
      
        openstudio_shading_surface_group = OpenStudio::Model::ShadingSurfaceGroup.new(openstudio_model)
        
        if @hash[:outdoor_shades]
          @hash[:outdoor_shades].each do |outdoor_shade|
            outdoor_shade = Shade.new(outdoor_shade)
            openstudio_outdoor_shade = outdoor_shade.to_openstudio(openstudio_model)
            openstudio_shading_surface_group.setSpace(openstudio_space)
            #set shading surface group for outdoor shade
            openstudio_outdoor_shade.setShadingSurfaceGroup(openstudio_shading_surface_group)
          end
        end

        openstudio_thermal_zone = OpenStudio::Model::ThermalZone.new(openstudio_model)
        openstudio_space.setThermalZone(openstudio_thermal_zone)

        if @hash[:properties][:energy][:program_type]
          space_type = openstudio_model.getSpaceTypeByName(@hash[:properties][:energy][:program_type])
          unless space_type.empty?
            space_type_object = space_type.get
          end
          openstudio_space.setSpaceType(space_type_object)
        end

        #check whether people object is specified for room
        if @hash[:properties][:energy][:people]
          people = openstudio_model.getPeopleByName(@hash[:properties][:energy][:people][:name])
          unless people.empty?
            people_object = people.get
            people_object.setSpace(openstudio_space)
          else 
            #create new people object if doesnt exist in model
            people_space = PeopleAbridged.new(@hash[:properties][:energy][:people])
            openstudio_people_space = people_space.to_openstudio(openstudio_model)
            openstudio_people_space.setSpace(openstudio_space)
          end
        end

        if @hash[:properties][:energy][:lighting]
          lighting = openstudio_model.getLightsByName(@hash[:properties][:energy][:lighting][:name])
          unless lighting.empty?
            lighting_object = lighting.get
            lighting_object.setSpace(openstudio_space)
          else
            lighting_space = LightingAbridged.new(@hash[:properties][:energy][:lighting])
            openstudio_lighting_space = lighting_space.to_openstudio(openstudio_model)
            openstudio_lighting_space.setSpace(openstudio_space)
          end
        end

        if @hash[:properties][:energy][:electric_equipment]
          electric_equipment = openstudio_model.getElectricEquipmentByName(@hash[:properties][:energy][:electric_equipment][:name])
          unless electric_equipment.empty?
            electric_equipment_object = electric_equipment.get
            electric_equipment_object.setSpace(openstudio_space)
          else
            electric_equipment_space = ElectricEquipmentAbridged.new(@hash[:properties][:energy][:electric_equipment])
            openstudio_electric_equipment_space = electric_equipment_space.to_openstudio(openstudio_model)
            openstudio_electric_equipment_space.setSpace(openstudio_space)
          end
        end
        
        if @hash[:properties][:energy][:gas_equipment]
          gas_equipment = openstudio_model.getGasEquipmentByName(@hash[:properties][:energy][:gas_equipment][:name])
          unless gas_equipment.empty?
            gas_equipment_object = gas_equipment.get
            gas_equipment_object.setSpace(openstudio_space)
          else
            gas_equipment_space = GasEquipmentAbridged.new(@hash[:properties][:energy][:gas_equipment])
            openstudio_gas_equipment_space = gas_equipment_space.to_openstudio(openstudio_model)
            openstudio_gas_equipment_space.setSpace(openstudio_space)
          end
        end

        if @hash[:properties][:energy][:infiltration]
          infiltration = openstudio_model.getSpaceInfiltrationDesignFlowRateByName(@hash[:properties][:energy][:infiltration][:name])
          unless infiltration.empty?
            infiltration_object = infiltration.get
            infiltration_object.setSpace(openstudio_space)
          else
            infiltration_space = InfiltrationAbridged.new(@hash[:properties][:energy][:infiltration])
            openstudio_infiltration_space = infiltration_space.to_openstudio(openstudio_model)
            openstudio_infiltration_space.setSpace(openstudio_space) 
          end
        end
          
        if @hash[:properties][:energy][:ventilation] 
          ventilation = openstudio_model.getDesignSpecificationOutdoorAirByName(@hash[:properties][:energy][:ventilation][:name])
          unless ventilation.empty?
            ventilation_object = ventilation.get
            ventilation_object.setSpace(openstudio_space)
          else
            ventilation_space = VentilationAbridged.new(@hash[:properties][:energy][:ventilation])
            openstudio_ventilation_space = ventilation_space.to_openstudio(openstudio_model)
            openstudio_space.setDesignSpecificationOutdoorAir(openstudio_ventilation_space)
          end
        end

        if @hash[:properties][:energy][:setpoint]
          #thermostat object is created because heating and cooling schedule are required
          #fields.
          setpoint_thermostat_space = SetpointThermostat.new(@hash[:properties][:energy][:setpoint])
          openstudio_setpoint_thermostat_space = setpoint_thermostat_space.to_openstudio(openstudio_model)
          #set thermostat to thermal zone
          openstudio_thermal_zone.setThermostatSetpointDualSetpoint(openstudio_setpoint_thermostat_space)
          #humidistat object is created if humidification or dehumidification schedule is
          #specified.
          if @hash[:properties][:energy][:setpoint][:humidification_schedule] or @hash[:properties][:energy][:setpoint][:dehumidification_schedule]
            setpoint_humidistat_space = SetpointHumidistat.new(@hash[:properties][:energy][:setpoint])
            openstudio_setpoint_humidistat_space = setpoint_humidistat_space.to_openstudio(openstudio_model)
            openstudio_thermal_zone.setZoneControlHumidistat(openstudio_setpoint_humidistat_space)
          end
        end

        if @hash[:properties][:energy][:hvac]
          system_type = @hash[:properties][:energy][:hvac][:type]
          case system_type
          when 'IdealAirSystem'
            ideal_air_system = IdealAirSystem.new(@hash[:properties][:energy][:hvac])
            openstudio_ideal_air_system = ideal_air_system.to_openstudio(openstudio_model)
            openstudio_ideal_air_system.addToThermalZone(openstudio_thermal_zone)
          end
        end

        openstudio_space
      end

    end #Room
  end #EnergyModel
end #Ladybug

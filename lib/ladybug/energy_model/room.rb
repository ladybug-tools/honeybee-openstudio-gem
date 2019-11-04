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

        default_construction_set = nil
        if @hash[:properties][:energy][:construction_set]
          construction_set_name = @hash[:properties][:energy][:construction_set]
          construction_set = openstudio_model.getDefaultConstructionSetByName(construction_set_name)
          unless construction_set.empty?
            default_construction_set = construction_set.get
          end
        end
        
        openstudio_space = OpenStudio::Model::Space.new(openstudio_model)
        openstudio_space.setName(@hash[:name])   
        openstudio_space.setDefaultConstructionSet(default_construction_set) if default_construction_set
      
        @hash[:faces].each do |face|
          face = Face.new(face)
          openstudio_face = face.to_openstudio(openstudio_model)
          openstudio_face.setSpace(openstudio_space)

          nil
        end

        @hash[:faces].each do |face|
          if face[:boundary_condition][:type] == 'Adiabatic' && !face[:properties][:energy][:construction]
            openstudio_surfaces = openstudio_space.surfaces.each do |surface|

              if surface.outsideBoundaryCondition == 'Adiabatic'
                default_construction_set = openstudio_space.getDefaultConstruction(surface) unless openstudio_space.getDefaultConstruction(surface).empty?
                default_interior_surface_construction_set = default_construction_set.defaultInteriorSurfaceConstructions
                default_interior_surface_construction_set = default_interior_surface_construction_set.get unless default_interior_surface_construction_set.empty?

                case surface.surfaceType
                when 'Wall'
                  interior_wall_construction = default_interior_surface_construction_set.wallConstruction
                  interior_wall_construction = interior_wall_construction.get unless interior_wall_construction.empty? 
                  surface.setConstruction(interior_wall_construction)
                when 'RoofCeiling'
                  interior_roofceiling_construction = default_interior_surface_construction_set.roofCeilingConstruction
                  interior_roofceiling_construction = interior_roofceiling_construction.get unless interior_roofceiling_construction.empty?
                  surface.setConstruction(interior_roofceiling_construction)
                when 'Floor'
                  interior_floor_construction = default_interior_surface_construction_set.floorConstruction
                  interior_floor_construction = interior_floor_construction.get unless interior_floor_construction.empty?
                  surface.setConstruction(interior_floor_construction)
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
            openstudio_shading_surface_group.setSpace(openstudio_surface)
            openstudio_outdoor_shade.setShadingSurfaceGroup(openstudio_shading_surface_group)
          end
        end

        openstudio_thermal_zone = OpenStudio::Model::ThermalZone.new(openstudio_model)
        openstudio_space.setThermalZone(openstudio_thermal_zone)

        if @hash[:properties][:energy][:program_type]
          space_type_object = nil
          space_type = openstudio_model.getSpaceTypeByName(@hash[:properties][:energy][:program_type])
          unless space_type.empty?
            space_type_object = space_type.get
          end
          openstudio_space.setSpaceType(space_type_object)
        end

        people_object = nil
        if @hash[:properties][:energy][:people]
          people = openstudio_model.getPeopleByName(@hash[:properties][:energy][:people][:name])
          unless people.empty?
            people_object = people.get
            people_object.setSpace(openstudio_space)
          end
        end

        if @hash[:properties][:energy][:lighting]
          lighting_object = nil
          lighting = openstudio_model.getLightsByName(@hash[:properties][:energy][:lighting][:name])
          unless lighting.empty?
            lighting_object = lighting.get
          end
          lighting_object.setSpace(openstudio_space)
        end

        if @hash[:properties][:energy][:electrical_equipment]
          electrical_equipment_object = nil
          electrical_equipment = openstudio_model.getElectricEquipmentByName(@hash[:properties][:energy][:electrical_equipment][:name])
          unless electrical_equipment.empty?
            electrical_equipment_object = electrical_equipment.get
          end
          electrical_equipment_object.setSpace(openstudio_space)
        end
        
        if @hash[:properties][:energy][:gas_equipment]
          gas_equipment_object = nil
          gas_equipment = openstudio_model.getGasEquipmentByName(@hash[:properties][:energy][:gas_equipment][:name])
          unless gas_equipment.empty?
            gas_equipment_object = gas_equipment.get
          end
          gas_equipment_object.setSpace(openstudio_space)
        end

        if @hash[:properties][:energy][:infiltration]
          infiltration_object = nil
          infiltration = openstudio_model.getSpaceInfiltrationDesignFlowRate(@hash[:properties][:energy][:infiltration][:name])
          unless infiltration_object.empty?
            infiltration_object = infiltration.get
          end
          infiltration_object.setSpace(openstudio_space)
        end
          
        if @hash[:properties][:energy][:ventilation] 
          ventilation_object = nil
          ventilation = openstudio_model.getDesignSpecificationOutdoorAirByName(@hash[:properties][:energy][:ventilation][:name])
          unless ventilation_object.empty?
            ventilation_object = ventilation.get
          end
          ventilation_object.setSpace(openstudio_space)
        end

        if @hash[:properties][:energy][:setpoint]
          setpoint_thermostat_object = nil
          setpoint_thermostat = openstudio_model.getThermostatSetpointDualSetpointByName(@hash[:properties][:energy][:setpoint][:name])
          unless setpoint_thermostat.empty?
            setpoint_thermostat_object = setpoint_thermostat.get
          end
          openstudio_thermal_zone.setThermostatSetpointDualSetpoint(setpoint_thermostat_object)
          if @hash[:properties][:energy][:setpoint][:humidification_schedule]
            setpoint_humidistat_object = nil
            setpoint_humidistat = openstudio_model.getZoneControlHumidistatByName(@hash[:properties][:energy][:setpoint][:name])
            unless setpoint_humidistat.empty?
              setpoint_humidistat_object = setpoint_humidistat.get
            end
            openstudio_thermal_zone.setZoneControlHumidistat(setpoint_humidistat_object)
          end
        end
      
        openstudio_space
      end

    end # Room
  end # EnergyModel
end # Ladybug

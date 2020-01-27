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

require 'from_honeybee/model_object'

require 'from_honeybee/geometry/face'
require 'from_honeybee/geometry/shade'

require 'from_honeybee/load/people'
require 'from_honeybee/load/lighting'
require 'from_honeybee/load/electric_equipment'
require 'from_honeybee/load/gas_equipment'
require 'from_honeybee/load/infiltration'
require 'from_honeybee/load/ventilation'
require 'from_honeybee/load/setpoint_thermostat'
require 'from_honeybee/load/setpoint_humidistat'

require 'openstudio'

module FromHoneybee
  class Room < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
      raise "Incorrect model type '#{@type}'" unless @type == 'Room'
    end

    def defaults
      @@schema[:components][:schemas][:RoomEnergyPropertiesAbridged][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      model_space = openstudio_model.getSpaceByName(@hash[:name])
      return model_space.get unless model_space.empty?
      nil 
    end

    def to_openstudio(openstudio_model)
      # create the space and thermal zone
      os_space = OpenStudio::Model::Space.new(openstudio_model)
      os_space.setName(@hash[:name])
      os_thermal_zone = OpenStudio::Model::ThermalZone.new(openstudio_model)
      os_thermal_zone.setName(@hash[:name])
      os_space.setThermalZone(os_thermal_zone)

      # assign the programtype
      if @hash[:properties][:energy][:program_type]
        space_type = openstudio_model.getSpaceTypeByName(@hash[:properties][:energy][:program_type])
        unless space_type.empty?
          space_type_object = space_type.get
          os_space.setSpaceType(space_type_object)
        end
      end

      # assign the constructionset
      if @hash[:properties][:energy][:construction_set]
        construction_set_name = @hash[:properties][:energy][:construction_set]
        # gets default construction set assigned to room from openstudio_model
        construction_set = openstudio_model.getDefaultConstructionSetByName(construction_set_name)
        unless construction_set.empty?
          default_construction_set = construction_set.get
          os_space.setDefaultConstructionSet(default_construction_set) 
        end
      end

      # assign the multiplier
      if @hash[:multiplier] and @hash[:multiplier] != 1
        os_thermal_zone.setMultiplier(@hash[:multiplier])
      end
      
      # assign all of the faces to the room
      @hash[:faces].each do |face|
        ladybug_face = Face.new(face)
        openstudio_surface = ladybug_face.to_openstudio(openstudio_model)
        openstudio_surface.setSpace(os_space)

        # TODO: process all air walls between Rooms

        # assign face-level shades if they exist
        if face[:outdoor_shades]
          os_shd_group = make_shade_group(openstudio_model, openstudio_surface, os_space)
          face[:outdoor_shades].each do |outdoor_shade|
            add_shade_to_group(openstudio_model, os_shd_group, outdoor_shade)
          end
        end

        # assign aperture-level shades if they exist
        if face[:apertures]
          face[:apertures].each do |aperture|
            if aperture[:outdoor_shades]
              unless os_shd_group
                os_shd_group = make_shade_group(openstudio_model, openstudio_surface, os_space)
              end
              aperture[:outdoor_shades].each do |outdoor_shade|
                add_shade_to_group(openstudio_model, os_shd_group, outdoor_shade)
              end
            end
          end
        end

        # assign door-level shades if they exist
        if face[:doors]
          face[:doors].each do |door|
            if door[:outdoor_shades]
              unless os_shd_group
                os_shd_group = make_shade_group(openstudio_model, openstudio_surface, os_space)
              end
              door[:outdoor_shades].each do |outdoor_shade|
                add_shade_to_group(openstudio_model, os_shd_group, outdoor_shade)
              end
            end
          end
        end

        # assign default interior construciton if Adiabatic and no assigned construction 
        if face[:boundary_condition][:type] == 'Adiabatic' && !face[:properties][:energy][:construction]
          if face[:face_type] != 'Wall'
            interior_construction = closest_interior_construction(openstudio_model, os_space, face[:face_type])
            unless interior_construction.nil?
              openstudio_surface.setConstruction(interior_construction)
            end
          end
        end
      end

      # assign any room-level outdoor shades if they exist
      if @hash[:outdoor_shades]
        os_shd_group = OpenStudio::Model::ShadingSurfaceGroup.new(openstudio_model)
        os_shd_group.setSpace(os_space)
        os_shd_group.setShadingSurfaceType("Space")
        @hash[:outdoor_shades].each do |outdoor_shade|
          add_shade_to_group(openstudio_model, os_shd_group, outdoor_shade)
        end
      end

      #check whether there are any load objects on the room overriding the programtype
      if @hash[:properties][:energy][:people]
        people = openstudio_model.getPeopleByName(@hash[:properties][:energy][:people][:name])
        unless people.empty?
          people_object = people.get
          people_object.setSpace(os_space)
        else
          people_space = PeopleAbridged.new(@hash[:properties][:energy][:people])
          openstudio_people_space = people_space.to_openstudio(openstudio_model)
          openstudio_people_space.setSpace(os_space)
        end
      end

      if @hash[:properties][:energy][:lighting]
        lighting = openstudio_model.getLightsByName(@hash[:properties][:energy][:lighting][:name])
        unless lighting.empty?
          lighting_object = lighting.get
          lighting_object.setSpace(os_space)
        else
          lighting_space = LightingAbridged.new(@hash[:properties][:energy][:lighting])
          openstudio_lighting_space = lighting_space.to_openstudio(openstudio_model)
          openstudio_lighting_space.setSpace(os_space)
        end
      end

      if @hash[:properties][:energy][:electric_equipment]
        electric_equipment = openstudio_model.getElectricEquipmentByName(
          @hash[:properties][:energy][:electric_equipment][:name])
        unless electric_equipment.empty?
          electric_equipment_object = electric_equipment.get
          electric_equipment_object.setSpace(os_space)
        else
          electric_equipment_space = ElectricEquipmentAbridged.new(@hash[:properties][:energy][:electric_equipment])
          openstudio_electric_equipment_space = electric_equipment_space.to_openstudio(openstudio_model)
          openstudio_electric_equipment_space.setSpace(os_space)
        end
      end
      
      if @hash[:properties][:energy][:gas_equipment]
        gas_equipment = openstudio_model.getGasEquipmentByName(
          @hash[:properties][:energy][:gas_equipment][:name])
        unless gas_equipment.empty?
          gas_equipment_object = gas_equipment.get
          gas_equipment_object.setSpace(os_space)
        else
          gas_equipment_space = GasEquipmentAbridged.new(@hash[:properties][:energy][:gas_equipment])
          openstudio_gas_equipment_space = gas_equipment_space.to_openstudio(openstudio_model)
          openstudio_gas_equipment_space.setSpace(os_space)
        end
      end

      if @hash[:properties][:energy][:infiltration]
        infiltration = openstudio_model.getSpaceInfiltrationDesignFlowRateByName(
          @hash[:properties][:energy][:infiltration][:name])
        unless infiltration.empty?
          infiltration_object = infiltration.get
          infiltration_object.setSpace(os_space)
        else
          infiltration_space = InfiltrationAbridged.new(@hash[:properties][:energy][:infiltration])
          openstudio_infiltration_space = infiltration_space.to_openstudio(openstudio_model)
          openstudio_infiltration_space.setSpace(os_space) 
        end
      end
        
      if @hash[:properties][:energy][:ventilation] 
        ventilation = openstudio_model.getDesignSpecificationOutdoorAirByName(
          @hash[:properties][:energy][:ventilation][:name])
        unless ventilation.empty?
          ventilation_object = ventilation.get
          ventilation_object.setSpace(os_space)
        else
          ventilation_space = VentilationAbridged.new(@hash[:properties][:energy][:ventilation])
          openstudio_ventilation_space = ventilation_space.to_openstudio(openstudio_model)
          os_space.setDesignSpecificationOutdoorAir(openstudio_ventilation_space)
        end
      end

      if @hash[:properties][:energy][:setpoint]
        #thermostat object is created because heating and cooling schedule are required
        #fields.
        setpoint_thermostat_space = SetpointThermostat.new(@hash[:properties][:energy][:setpoint])
        openstudio_setpoint_thermostat_space = setpoint_thermostat_space.to_openstudio(openstudio_model)
        #set thermostat to thermal zone
        os_thermal_zone.setThermostatSetpointDualSetpoint(openstudio_setpoint_thermostat_space)
        #humidistat object is created if humidification or dehumidification schedule is
        #specified.
        if @hash[:properties][:energy][:setpoint][:humidification_schedule] or @hash[:properties][:energy][:setpoint][:dehumidification_schedule]
          setpoint_humidistat_space = SetpointHumidistat.new(@hash[:properties][:energy][:setpoint])
          openstudio_setpoint_humidistat_space = setpoint_humidistat_space.to_openstudio(openstudio_model)
          os_thermal_zone.setZoneControlHumidistat(openstudio_setpoint_humidistat_space)
        end
      end

      os_space
    end

    # method to make a space-assigned Shade group for shades assigned to parent objects
    def make_shade_group(openstudio_model, openstudio_surface, os_space)
      os_shd_group = OpenStudio::Model::ShadingSurfaceGroup.new(openstudio_model)
      os_shd_group.setShadedSurface(openstudio_surface)
      os_shd_group.setSpace(os_space)
      os_shd_group.setShadingSurfaceType("Space")

      os_shd_group
    end

    # method to create a Shade and add it to a shade group
    def add_shade_to_group(openstudio_model, os_shd_group, outdoor_shade)
      hb_outdoor_shade = Shade.new(outdoor_shade)
      os_outdoor_shade = hb_outdoor_shade.to_openstudio(openstudio_model)
      os_outdoor_shade.setShadingSurfaceGroup(os_shd_group)
    end
  
    # method to check for the closest-assigned interior ceiling or floor construction
    def closest_interior_construction(openstudio_model, os_space, surface_type)
      # first check the space-assigned construction set
      constr_set_space = os_space.defaultConstructionSet
      unless constr_set_space.empty?
        constr_set_space_object = constr_set_space.get
        default_interior_srf_set = constr_set_space_object.defaultInteriorSurfaceConstructions
        unless default_interior_srf_set.empty?
          default_interior_srf_set = default_interior_srf_set.get
          if surface_type == 'RoofCeiling'
            interior_construction = default_interior_srf_set.roofCeilingConstruction
          else
            interior_construction = default_interior_srf_set.floorConstruction
          end
          unless interior_construction.empty?
            return interior_construction.get
          end
        end
      end
      # if no construction was found, check the building-assigned construction set
      building = openstudio_model.building
      unless building.empty?
        building = building.get
        construction_set_bldg = building.defaultConstructionSet
        unless construction_set_bldg.empty?
          construction_set_bldg_object = construction_set_bldg.get
          default_interior_srf_set = construction_set_bldg_object.defaultInteriorSurfaceConstructions
          unless default_interior_srf_set.empty?
            default_interior_srf_set = default_interior_srf_set.get
            if surface_type == 'RoofCeiling'
              interior_construction = default_interior_srf_set.roofCeilingConstruction
            else
              interior_construction = default_interior_srf_set.floorConstruction
            end
            unless interior_construction.empty?
              return interior_construction.get
            end
          end
        end
      end
      nil  # no construction was found
    end

  end #Room
end #FromHoneybee

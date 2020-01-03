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

require 'openstudio'

module Ladybug
  module EnergyModel
    class ConstructionSetAbridged < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'ConstructionSetAbridged'
      end

      def defaults
        result = {}
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getDefaultConstructionSetByName(@hash[:name])
        return object.get if object.is_initialized
        nil
      end


      def create_openstudio_object(openstudio_model)
        openstudio_construction_set = OpenStudio::Model::DefaultConstructionSet.new(openstudio_model)
        openstudio_construction_set.setName(@hash[:name])
        interior_surface_construction = OpenStudio::Model::DefaultSurfaceConstructions.new(openstudio_model)
        exterior_surface_construction = OpenStudio::Model::DefaultSurfaceConstructions.new(openstudio_model)
        ground_surface_construction = OpenStudio::Model::DefaultSurfaceConstructions.new(openstudio_model)
        interior_subsurface_construction = OpenStudio::Model::DefaultSubSurfaceConstructions.new(openstudio_model)
        exterior_subsurface_construction = OpenStudio::Model::DefaultSubSurfaceConstructions.new(openstudio_model)
        

        if @hash[:wall_set]
            if @hash[:wall_set][:interior_construction]
                interior_wall_object = openstudio_model.getConstructionByName(@hash[:wall_set][:interior_construction])
                unless interior_wall_object.empty?
                    interior_wall = interior_wall_object.get
                    interior_surface_construction.setWallConstruction(interior_wall)
                    openstudio_construction_set.setDefaultInteriorSurfaceConstructions(interior_surface_construction)
                end
            end
            if @hash[:wall_set][:exterior_construction]
                exterior_wall_object = openstudio_model.getConstructionByName(@hash[:wall_set][:exterior_construction])
                unless exterior_wall_object.empty?
                    exterior_wall = exterior_wall_object.get
                    exterior_surface_construction.setWallConstruction(exterior_wall)
                    openstudio_construction_set.setDefaultExteriorSurfaceConstructions(exterior_surface_construction)
                end
            end
            if @hash[:wall_set][:ground_construction]
                ground_wall_object = openstudio_model.getConstructionByName(@hash[:wall_set][:ground_construction])
                unless ground_wall_object.empty?
                    ground_wall = ground_wall_object.get
                    ground_surface_construction.setWallConstruction(ground_wall)
                    openstudio_construction_set.setDefaultGroundContactSurfaceConstructions(ground_surface_construction)
                end
            end
        end

        if @hash[:floor_set]
            if @hash[:floor_set][:interior_construction]
                interior_floor_object = openstudio_model.getConstructionByName(@hash[:floor_set][:interior_construction])
                unless interior_floor_object.empty?
                    interior_floor = interior_floor_object.get
                    interior_surface_construction.setFloorConstruction(interior_floor)
                    openstudio_construction_set.setDefaultInteriorSurfaceConstructions(interior_surface_construction)
                end
            end
            if @hash[:floor_set][:exterior_construction]
                exterior_floor_object = openstudio_model.getConstructionByName(@hash[:floor_set][:exterior_construction])
                unless exterior_floor_object.empty?
                    exterior_floor = exterior_floor_object.get
                    exterior_surface_construction.setFloorConstruction(exterior_floor)
                    openstudio_construction_set.setDefaultExteriorSurfaceConstructions(exterior_surface_construction)
                end
            end
            if @hash[:floor_set][:ground_construction]
                ground_floor_object = openstudio_model.getConstructionByName(@hash[:floor_set][:ground_construction])
                unless ground_floor_object.empty?
                    ground_floor = ground_floor_object.get
                    ground_surface_construction.setFloorConstruction(ground_floor)
                    openstudio_construction_set.setDefaultGroundContactSurfaceConstructions(ground_surface_construction)
                end
            end
        end

        if @hash[:roof_ceiling_set]
            if @hash[:roof_ceiling_set][:interior_construction]
                interior_ceiling_object = openstudio_model.getConstructionByName(@hash[:roof_ceiling_set][:interior_construction])
                unless interior_ceiling_object.empty?
                    interior_ceiling = interior_ceiling_object.get
                    interior_surface_construction.setRoofCeilingConstruction(interior_ceiling)
                    openstudio_construction_set.setDefaultInteriorSurfaceConstructions(interior_surface_construction)
                end
            end
            if @hash[:roof_ceiling_set][:exterior_construction]
                exterior_ceiling_object = openstudio_model.getConstructionByName(@hash[:roof_ceiling_set][:exterior_construction])
                unless exterior_ceiling_object.empty?
                    exterior_ceiling = exterior_ceiling_object.get
                    exterior_surface_construction.setRoofCeilingConstruction(exterior_ceiling)
                    openstudio_construction_set.setDefaultExteriorSurfaceConstructions(exterior_surface_construction)
                end
            end
            if @hash[:roof_ceiling_set][:ground_construction]
                ground_ceiling_object = openstudio_model.getConstructionByName(@hash[:roof_ceiling_set][:ground_construction])
                unless ground_ceiling_object.empty?
                    ground_ceiling = ground_ceiling_object.get
                    ground_surface_construction.setRoofCeilingConstruction(ground_ceiling)
                    openstudio_construction_set.setDefaultGroundContactSurfaceConstructions(ground_surface_construction)
                end
            end
        end
       
        if @hash[:aperture_set]
            if @hash[:aperture_set][:interior_construction]
                interior_aperture_object = openstudio_model.getConstructionByName(@hash[:aperture_set][:interior_construction])
                unless interior_aperture_object.empty?
                    interior_aperture = interior_aperture_object.get
                    interior_subsurface_construction.setFixedWindowConstruction(interior_aperture)
                    interior_subsurface_construction.setOperableWindowConstruction(interior_aperture)
                    openstudio_construction_set.setDefaultInteriorSubSurfaceConstructions(interior_subsurface_construction)
                end
            end
            if @hash[:aperture_set][:window_construction]
                window_aperture_object = openstudio_model.getConstructionByName(@hash[:aperture_set][:window_construction])
                unless window_aperture_object.empty?
                    window_aperture = window_aperture_object.get
                    exterior_subsurface_construction.setFixedWindowConstruction(window_aperture)
                    openstudio_construction_set.setDefaultExteriorSubSurfaceConstructions(exterior_subsurface_construction)
                end
            end
            if @hash[:aperture_set][:skylight_construction]
                skylight_aperture_object = openstudio_model.getConstructionByName(@hash[:aperture_set][:skylight_construction])
                unless skylight_aperture_object.empty?
                    skylight_aperture = skylight_aperture_object.get
                    exterior_subsurface_construction.setSkylightConstruction(skylight_aperture)
                    openstudio_construction_set.setDefaultExteriorSubSurfaceConstructions(exterior_subsurface_construction)
                end
            end
            if @hash[:aperture_set][:operable_construction]
                operable_aperture_object = openstudio_model.getConstructionByName(@hash[:aperture_set][:operable_construction])
                unless operable_aperture_object.empty?
                    operable_aperture = operable_aperture_object.get
                    exterior_subsurface_construction.setOperableWindowConstruction(operable_aperture)
                    openstudio_construction_set.setDefaultExteriorSubSurfaceConstructions(exterior_subsurface_construction)
                end
            end
        end    
        
        if @hash[:door_set]
            if @hash[:door_set][:interior_construction]
                interior_door_object = openstudio_model.getConstructionByName(@hash[:door_set][:interior_construction])
                unless interior_door_object.empty?
                    interior_door = interior_door_object.get
                    interior_subsurface_construction.setDoorConstruction(interior_door)
                    openstudio_construction_set.setDefaultInteriorSubSurfaceConstructions(interior_subsurface_construction)
                end
            end
            if @hash[:door_set][:exterior_construction]
                exterior_door_object = openstudio_model.getConstructionByName(@hash[:door_set][:exterior_construction])
                unless exterior_door_object.empty?
                    exterior_door = exterior_door_object.get
                    exterior_subsurface_construction.setDoorConstruction(exterior_door)
                    openstudio_construction_set.setDefaultExteriorSubSurfaceConstructions(exterior_subsurface_construction)
                end
            end
            if @hash[:door_set][:overhead_construction]
                overhead_door_object = openstudio_model.getConstructionByName(@hash[:door_set][:overhead_construction])
                unless overhead_door_object.empty?
                    overhead_door = overhead_door_object.get
                    exterior_subsurface_construction.setOverheadDoorConstruction(overhead_door)
                    openstudio_construction_set.setDefaultExteriorSubSurfaceConstructions(exterior_subsurface_construction)
                end
            end
            if @hash[:door_set][:exterior_glass_construction]
                exterior_glass_door_object = openstudio_model.getConstructionByName(@hash[:door_set][:exterior_glass_construction])
                unless exterior_glass_door_object.empty?
                    exterior_glass_door = exterior_glass_door_object.get
                    exterior_subsurface_construction.setGlassDoorConstruction(exterior_glass_door)
                    openstudio_construction_set.setDefaultExteriorSubSurfaceConstructions(exterior_subsurface_construction)
                end
            end
            if @hash[:door_set][:interior_glass_construction]
                interior_glass_door_object = openstudio_model.getConstructionByName(@hash[:door_set][:interior_glass_construction])
                unless interior_glass_door_object.empty?
                    interior_glass_door = interior_glass_door_object.get
                    interior_subsurface_construction.setGlassDoorConstruction(interior_glass_door)
                    openstudio_construction_set.setDefaultInteriorSubSurfaceConstructions(interior_subsurface_construction)
                end
            end
        end
        
        if @hash[:shade_construction]
            shade_construction = nil
            if @hash[:shade_construction]
                shade_construction_object = openstudio_model.getConstructionByName(@hash[:shade_construction])
                unless shade_construction_object.empty?
                    shade_construction = shade_construction_object.get
                    openstudio_construction_set.setSpaceShadingConstruction(shade_construction)
                end
            end
        end

        openstudio_construction_set
      end
    end #ConstructionSetAbridged
  end #EnergyModel
end #Ladybug

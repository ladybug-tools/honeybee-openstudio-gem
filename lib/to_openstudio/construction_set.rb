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

require 'honeybee/construction_set'

require 'to_openstudio/model_object'

module Honeybee
  class ConstructionSetAbridged

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getDefaultConstructionSetByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create the constructionset object
      os_constr_set = OpenStudio::Model::DefaultConstructionSet.new(openstudio_model)
      os_constr_set.setName(@hash[:identifier])

      int_surf_const = OpenStudio::Model::DefaultSurfaceConstructions.new(openstudio_model)
      ext_surf_const = OpenStudio::Model::DefaultSurfaceConstructions.new(openstudio_model)
      grnd_surf_const = OpenStudio::Model::DefaultSurfaceConstructions.new(openstudio_model)
      int_subsurf_const = OpenStudio::Model::DefaultSubSurfaceConstructions.new(openstudio_model)
      ext_subsurf_const = OpenStudio::Model::DefaultSubSurfaceConstructions.new(openstudio_model)

      os_constr_set.setDefaultInteriorSurfaceConstructions(int_surf_const)
      os_constr_set.setDefaultExteriorSurfaceConstructions(ext_surf_const)
      os_constr_set.setDefaultGroundContactSurfaceConstructions(grnd_surf_const)
      os_constr_set.setDefaultInteriorSubSurfaceConstructions(int_subsurf_const)
      os_constr_set.setDefaultExteriorSubSurfaceConstructions(ext_subsurf_const)

      # assign any constructions in the wall set
      if @hash[:wall_set]
        if @hash[:wall_set][:interior_construction]
          int_wall_ref = openstudio_model.getConstructionByName(@hash[:wall_set][:interior_construction])
          unless int_wall_ref.empty?
            interior_wall = int_wall_ref.get
            int_surf_const.setWallConstruction(interior_wall)
            os_constr_set.setAdiabaticSurfaceConstruction(interior_wall)
          end
        end
        if @hash[:wall_set][:exterior_construction]
          ext_wall_ref = openstudio_model.getConstructionByName(@hash[:wall_set][:exterior_construction])
          unless ext_wall_ref.empty?
            exterior_wall = ext_wall_ref.get
            ext_surf_const.setWallConstruction(exterior_wall)
          end
        end
        if @hash[:wall_set][:ground_construction]
          grd_wall_ref = openstudio_model.getConstructionByName(@hash[:wall_set][:ground_construction])
          unless grd_wall_ref.empty?
            ground_wall = grd_wall_ref.get
            grnd_surf_const.setWallConstruction(ground_wall)
          end
        end
      end

      # assign any constructions in the floor set
      if @hash[:floor_set]
        if @hash[:floor_set][:interior_construction]
          constr_id_int = openstudio_model.getConstructionByName(@hash[:floor_set][:interior_construction])
          assign_constr_to_set_int(openstudio_model, int_surf_const, 'Floor',
            constr_id_int)
        end
        if @hash[:floor_set][:exterior_construction]
          constr_id_ext = openstudio_model.getConstructionByName(@hash[:floor_set][:exterior_construction])
          assign_constr_to_set_ext(openstudio_model, ext_surf_const, 'Floor',
            constr_id_ext
          )
        end
        if @hash[:floor_set][:ground_construction]
          constr_id_grd = openstudio_model.getConstructionByName(@hash[:floor_set][:ground_construction])
          assign_constr_to_set_grd(openstudio_model, grnd_surf_const, 'Floor',
            constr_id_grd)
        end
      end

      # assign any constructions in the roof ceiling set
      if @hash[:roof_ceiling_set]
        if @hash[:roof_ceiling_set][:interior_construction]
          constr_id_int = openstudio_model.getConstructionByName(@hash[:roof_ceiling_set][:interior_construction])
          assign_constr_to_set_int(openstudio_model, int_surf_const, 'Roof',
            constr_id_int)
        end
        if @hash[:roof_ceiling_set][:exterior_construction]
          constr_id_ext = openstudio_model.getConstructionByName(@hash[:roof_ceiling_set][:exterior_construction])
          assign_constr_to_set_ext(openstudio_model, ext_surf_const, 'Roof',
            constr_id_ext)
        end
        if @hash[:roof_ceiling_set][:ground_construction]
          constr_id_grd = openstudio_model.getConstructionByName(@hash[:roof_ceiling_set][:ground_construction])
          assign_constr_to_set_grd(openstudio_model, grnd_surf_const, 'Roof',
            constr_id_grd)
        end
      end

      # assign any constructions in the aperture set
      if @hash[:aperture_set]
        if @hash[:aperture_set][:interior_construction]
          interior_aperture = get_window_construction(openstudio_model, @hash[:aperture_set][:interior_construction])
          unless interior_aperture.nil?
            int_subsurf_const.setFixedWindowConstruction(interior_aperture)
            int_subsurf_const.setOperableWindowConstruction(interior_aperture)
          end
        end
        if @hash[:aperture_set][:window_construction]
          window_aperture = get_window_construction(openstudio_model, @hash[:aperture_set][:window_construction])
          unless window_aperture.nil?
            ext_subsurf_const.setFixedWindowConstruction(window_aperture)
          end
        end
        if @hash[:aperture_set][:skylight_construction]
          skylight_aperture = get_window_construction(openstudio_model, @hash[:aperture_set][:skylight_construction])
          unless skylight_aperture.nil?
            ext_subsurf_const.setSkylightConstruction(skylight_aperture)
          end
        end
        if @hash[:aperture_set][:operable_construction]
          operable_aperture = get_window_construction(openstudio_model, @hash[:aperture_set][:operable_construction])
          unless operable_aperture.nil?
            ext_subsurf_const.setOperableWindowConstruction(operable_aperture)
          end
        end
      end

      # assign any constructions in the door set
      if @hash[:door_set]
        if @hash[:door_set][:interior_construction]
          int_door_ref = openstudio_model.getConstructionByName(
            @hash[:door_set][:interior_construction])
          unless int_door_ref.empty?
            interior_door = int_door_ref.get
            int_subsurf_const.setDoorConstruction(interior_door)
          end
        end
        if @hash[:door_set][:exterior_construction]
          ext_door_ref = openstudio_model.getConstructionByName(
            @hash[:door_set][:exterior_construction])
          unless ext_door_ref.empty?
            exterior_door = ext_door_ref.get
            ext_subsurf_const.setDoorConstruction(exterior_door)
          end
        end
        if @hash[:door_set][:overhead_construction]
          overhead_door_ref = openstudio_model.getConstructionByName(
            @hash[:door_set][:overhead_construction])
          unless overhead_door_ref.empty?
            overhead_door = overhead_door_ref.get
            ext_subsurf_const.setOverheadDoorConstruction(overhead_door)
          end
        end
        if @hash[:door_set][:exterior_glass_construction]
          exterior_glass_door = get_window_construction(openstudio_model, @hash[:door_set][:exterior_glass_construction])
          unless exterior_glass_door.nil?
            ext_subsurf_const.setGlassDoorConstruction(exterior_glass_door)
          end
        end
        if @hash[:door_set][:interior_glass_construction]
          interior_glass_door = get_window_construction(openstudio_model, @hash[:door_set][:interior_glass_construction])
          unless interior_glass_door.nil?
            int_subsurf_const.setGlassDoorConstruction(interior_glass_door)
          end
        end
      end

      # assign any shading constructions to construction set
      if @hash[:shade_construction]
        shade_ref = openstudio_model.getConstructionByName(@hash[:shade_construction])
        unless shade_ref.empty?
          shade_construction = shade_ref.get
          os_constr_set.setSpaceShadingConstruction(shade_construction)
        end
      end

      # assign any air boundary constructions to construction set
      if @hash[:air_boundary_construction]
        air_ref = openstudio_model.getConstructionAirBoundaryByName(
          @hash[:air_boundary_construction])
        unless air_ref.empty?
          air_construction = air_ref.get
          os_constr_set.setInteriorPartitionConstruction(air_construction)
        end
      end

      os_constr_set
    end

    # get interior construction subset
    def assign_constr_to_set_int(openstudio_model, constr_subset, face_type, constr_id_int)
      unless constr_id_int.empty?
        constr_id = constr_id_int.get
        check_constr_type(constr_id, face_type, constr_subset)
      end
    end

    # get exterior construction subset
    def assign_constr_to_set_ext(openstudio_model, constr_subset, face_type, constr_id_ext)
      unless constr_id_ext.empty?
        constr_id = constr_id_ext.get
        check_constr_type(constr_id, face_type, constr_subset)
      end
    end

    # get ground construction subset
    def assign_constr_to_set_grd(openstudio_model, constr_subset, face_type, constr_id_grd)
      unless constr_id_grd.empty?
        constr_id = constr_id_grd.get
        check_constr_type(constr_id, face_type, constr_subset)
      end
    end

    # check face type and assign to construction subset
    def check_constr_type(constr_id, face_type, constr_subset)
      if face_type == 'Wall'
        constr_subset.setWallConstruction(constr_id)
      elsif face_type == 'Floor'
        constr_subset.setFloorConstruction(constr_id)
      else
       constr_subset.setRoofCeilingConstruction(constr_id)
      end
    end
    
    # assign window construction with a check for dynamic constructions
    def get_window_construction(openstudio_model, construction_identifier)
      os_construction = nil
      constr_ref = openstudio_model.getConstructionByName(construction_identifier)
      if !constr_ref.empty?
        os_construction = constr_ref.get
      elsif !$window_dynamic_hash.nil? && !$window_dynamic_hash[construction_identifier].nil?
        os_construction = $window_dynamic_hash[construction_identifier].constructions[0]
      end

      os_construction
    end

  end #ConstructionSetAbridged
end #Honeybee

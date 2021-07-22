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
require 'from_openstudio/model_object'

module Honeybee
  class ConstructionSetAbridged < ModelObject

    def self.from_construction_set(construction_set)
        # create an empty hash
        hash = {}
        hash[:type] = 'ConstructionSetAbridged'
        # set hash values from OpenStudio Object
        hash[:identifier] = construction_set.nameString
        hash[:wall_set] = {}
        hash[:floor_set] = {}
        hash[:aperture_set] = {}
        hash[:door_set] = {}
        hash[:roof_ceiling_set] = {}

        # get interior surface constructions
        unless construction_set.defaultInteriorSurfaceConstructions.empty?
          int_surf_construction = construction_set.defaultInteriorSurfaceConstructions.get
          # get interior wall construction
          unless int_surf_construction.wallConstruction.empty?
            int_wall_const = int_surf_construction.wallConstruction.get
            hash[:wall_set][:interior_construction] = int_wall_const.nameString
          end
          # get interior floor construction
          unless int_surf_construction.floorConstruction.empty?
            int_floor_const = int_surf_construction.floorConstruction.get
            hash[:floor_set][:interior_construction] = int_floor_const.nameString
          end
          # get interior roofceiling construction
          unless int_surf_construction.roofCeilingConstruction.empty?
            int_roof_const = int_surf_construction.roofCeilingConstruction.get
            hash[:roof_ceiling_set][:interior_construction] = int_roof_const.nameString
          end
        end

        # get interior subsurface constructions
        unless construction_set.defaultInteriorSubSurfaceConstructions.empty?
          int_subsurf_const = construction_set.defaultInteriorSubSurfaceConstructions.get
          unless int_subsurf_const.fixedWindowConstruction.empty?
            int_wind_const = int_subsurf_const.fixedWindowConstruction.get
            hash[:aperture_set][:window_construction] = int_wind_const.nameString
          end
          # get interior door construction
          unless int_subsurf_const.doorConstruction.empty?
            int_door_const = int_subsurf_const.doorConstruction.get
            hash[:door_set][:interior_construction] = int_door_const.nameString
          end
          # get interior glass door construction
          unless int_subsurf_const.glassDoorConstruction.empty?
            int_glass_door_const = int_subsurf_const.glassDoorConstruction.get
            hash[:door_set][:interior_glass_construction] = int_glass_door_const.nameString
          end
        end
        
        # get exterior surface constructions
        unless construction_set.defaultExteriorSurfaceConstructions.empty?
          ext_surf_const = construction_set.defaultExteriorSurfaceConstructions.get
          # get exterior wall construction
          unless ext_surf_const.wallConstruction.empty?
            ext_wall_const = ext_surf_const.wallConstruction.get
            hash[:wall_set][:exterior_construction] = ext_wall_const.nameString
          end
          # get exterior floor construction
          unless ext_surf_const.floorConstruction.empty?
            ext_floor_const = ext_surf_const.floorConstruction.get
            hash[:floor_set][:exterior_construction] = ext_floor_const.nameString
          end
          # get exterior roofceiling construction
          unless ext_surf_const.roofCeilingConstruction.empty?
            ext_roof_const = ext_surf_const.roofCeilingConstruction.get
            hash[:roof_ceiling_set][:exterior_construction] = ext_roof_const.nameString
          end
        end

        # get exterior subsurface construction
        unless construction_set.defaultExteriorSubSurfaceConstructions.empty?
          ext_subsurf_const = construction_set.defaultExteriorSubSurfaceConstructions.get
          # get exterior operable window construction
          unless ext_subsurf_const.operableWindowConstruction.empty?
            ext_wind_const = ext_subsurf_const.operableWindowConstruction.get
            hash[:aperture_set][:operable_construction] = ext_wind_const.nameString
          end
          # get exterior skylight construction
          unless ext_subsurf_const.skylightConstruction.empty?
            ext_skylight_const = ext_subsurf_const.skylightConstruction.get
            hash[:aperture_set][:skylight_construction] = ext_skylight_const.nameString
          end
          # get exterior door construction
          unless ext_subsurf_const.doorConstruction.empty?
            ext_door_const = ext_subsurf_const.doorConstruction.get
            hash[:door_set][:exterior_construction] = ext_door_const.nameString
          end
          # get exterior overhead door construction
          unless ext_subsurf_const.overheadDoorConstruction.empty?
            ext_ovhd_door_const = ext_subsurf_const.overheadDoorConstruction.get
            hash[:door_set][:overhead_construction] = ext_ovhd_door_const.nameString
          end
        end

        hash

    end
  end # ConstructionSetAbridged
end # Honeybee

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

require 'honeybee/model_object'

module Honeybee
  class Face < ModelObject

    def self.from_surface(surface, site_transformation)
      hash = {}
      hash[:type] = 'Face'
      hash[:identifier] = clean_identifier(surface.nameString)
      hash[:display_name] = clean_display_name(surface.nameString)
      hash[:user_data] = {handle: surface.handle.to_s}
      hash[:properties] = properties_from_surface(surface)
      hash[:geometry] = geometry_from_surface(surface, site_transformation)
      hash[:face_type] = face_type_from_surface(surface)
      hash[:boundary_condition] = boundary_condition_from_surface(surface)

      apertures = apertures_from_surface(surface, site_transformation)
      hash[:apertures] = apertures if !apertures.empty?

      doors = doors_from_surface(surface, site_transformation)
      hash[:doors] = doors if !doors.empty?

      indoor_shades = indoor_shades_from_surface(surface)
      hash[:indoor_shades] = indoor_shades if !indoor_shades.empty?

      outdoor_shades = outdoor_shades_from_surface(surface)
      hash[:outdoor_shades] = outdoor_shades if !outdoor_shades.empty?

      hash
    end

    def self.properties_from_surface(surface)
      hash = {}
      hash[:type] = 'FacePropertiesAbridged'
      hash[:energy] = energy_properties_from_surface(surface)
      hash
    end

    def self.energy_properties_from_surface(surface)
      hash = {}
      hash[:type] = 'FaceEnergyPropertiesAbridged'

      unless surface.isConstructionDefaulted
        construction = surface.construction
        if !construction.empty?
          constr_id = construction.get.nameString
          unless $opaque_constructions[constr_id].nil?
            hash[:construction] = constr_id
          end
        end
      end

      hash
    end

    def self.geometry_from_surface(surface, site_transformation)
      result = {}
      result[:type] = 'Face3D'
      result[:boundary] = []
      vertices = site_transformation * surface.vertices
      vertices.each do |v|
        result[:boundary] << [v.x, v.y, v.z]
      end
      result
    end

    def self.face_type_from_surface(surface)
      # "Wall", "Floor", "RoofCeiling", "AirBoundary"
      result = nil
      surface_type = surface.surfaceType
      if surface.isAirWall
        result = 'AirBoundary'
      elsif /Wall/i.match(surface_type)
        result = 'Wall'
      elsif /Floor/i.match(surface_type)
        result = 'Floor'
      elsif /RoofCeiling/i.match(surface_type)
        result = 'RoofCeiling'
      end
      result
    end

    def self.boundary_condition_from_surface(surface)
      result = {}
      surface_bc = surface.outsideBoundaryCondition
      adjacent_surface = surface.adjacentSurface
      if !adjacent_surface.empty?
        adjacent_space = clean_identifier(adjacent_surface.get.space.get.nameString)
        adjacent_surface = clean_identifier(adjacent_surface.get.nameString)
        result = {type: 'Surface', boundary_condition_objects: [adjacent_surface, adjacent_space]}
      elsif surface.isGroundSurface
        result = {type: 'Ground'}
      elsif surface_bc == 'Adiabatic'
        result = {type: 'Adiabatic'}
      else
        sun_exposure = (surface.sunExposure == 'SunExposed')
        wind_exposure = (surface.windExposure == 'WindExposed')
        view_factor = surface.viewFactortoGround
        if view_factor.empty?
          view_factor = {type: 'Autocalculate'}
        else
          view_factor = view_factor.get
        end
        result = {type: 'Outdoors', sun_exposure: sun_exposure,
                  wind_exposure: wind_exposure, view_factor: view_factor}
      end
      result
    end

    def self.apertures_from_surface(surface, site_transformation)
      result = []
      surface.subSurfaces.each do |sub_surface|
        sub_surface_type = sub_surface.subSurfaceType
        if !/Door/i.match(sub_surface_type)
          result << Aperture.from_sub_surface(sub_surface, site_transformation)
        end
      end
      result
    end

    def self.doors_from_surface(surface, site_transformation)
      result = []
      surface.subSurfaces.each do |sub_surface|
        sub_surface_type = sub_surface.subSurfaceType
        if /Door/i.match(sub_surface_type)
          result << Door.from_sub_surface(sub_surface, site_transformation)
        end
      end
      result
    end

    def self.indoor_shades_from_surface(surface)
      []
    end

    def self.outdoor_shades_from_surface(surface)
      result = []
      surface.shadingSurfaceGroups.each do |shading_surface_group|
        site_transformation = shading_surface_group.siteTransformation
        shading_surface_group.shadingSurfaces.each do |shading_surface|
          result << Shade.from_shading_surface(shading_surface, site_transformation)
        end
      end
      result
    end

  end #Face
end #Honeybee

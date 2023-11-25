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

require 'honeybee/geometry/face'

require 'to_openstudio/model_object'

module Honeybee
  class Face < ModelObject

    def find_existing_openstudio_object(openstudio_model)
      model_surf = openstudio_model.getSurfaceByName(@hash[:identifier])
      return model_surf.get unless model_surf.empty?
      nil
    end

    def to_openstudio(openstudio_model)
      # get the vertices from the face
      if @hash[:geometry][:vertices].nil?
        hb_verts = @hash[:geometry][:boundary]
      else
        hb_verts = @hash[:geometry][:vertices]
      end

      # reorder the vertices to ensure they start from the upper-left corner
      os_vertices = OpenStudio::Point3dVector.new
      hb_verts.each do |vertex|
        os_vertices << OpenStudio::Point3d.new(vertex[0], vertex[1], vertex[2])
      end

      # create the openstudio surface
      os_surface = OpenStudio::Model::Surface.new(os_vertices, openstudio_model)
      os_surface.setName(@hash[:identifier])
      unless @hash[:display_name].nil?
        os_surface.setDisplayName(@hash[:display_name])
      end

      # assign the type
      os_surface.setSurfaceType(@hash[:face_type])

      if @hash[:properties].key?(:energy)
        # assign the construction if it is present
        if @hash[:properties][:energy][:construction]
          construction_identifier = @hash[:properties][:energy][:construction]
          construction = openstudio_model.getConstructionByName(construction_identifier)
          unless construction.empty?
            os_construction = construction.get
            os_surface.setConstruction(os_construction)
          end
        end

        # assign the AFN crack if it's specified and we are not using simple infiltration
        if !$use_simple_vent && @hash[:properties][:energy][:vent_crack]
          unless $interior_afn_srf_hash[@hash[:identifier]]  # interior crack that's been accounted for
            vent_crack = @hash[:properties][:energy][:vent_crack]
            # create the crack object for using default values
            flow_exponent = crack_defaults[:flow_exponent][:default].to_f
            os_crack = OpenStudio::Model::AirflowNetworkCrack.new(
              openstudio_model, vent_crack[:flow_coefficient], flow_exponent,
              $afn_reference_crack)

            # assign the flow exponent if it's specified
            if vent_crack[:flow_exponent]
              os_crack.setAirMassFlowExponent(vent_crack[:flow_exponent])
            end

            # if it's a Surface boundary condition ensure the neighbor is not written as a duplicate
            if @hash[:boundary_condition][:type] == 'Surface'
              $interior_afn_srf_hash[@hash[:boundary_condition][:boundary_condition_objects][0]] = true
            end

            # create the AirflowNetworkSurface
            os_afn_srf = os_surface.getAirflowNetworkSurface(os_crack)

          end
        end
      end

      # assign the boundary condition
      boundary_condition = @hash[:boundary_condition][:type]
      case boundary_condition
      when 'Outdoors'
        if @hash[:boundary_condition][:sun_exposure] == false
          os_surface.setSunExposure('NoSun')
        else
          os_surface.setSunExposure('SunExposed')
        end
        if @hash[:boundary_condition][:wind_exposure] == false
          os_surface.setWindExposure('NoWind')
        else
          os_surface.setWindExposure('WindExposed')
        end
        if @hash[:boundary_condition][:view_factor].is_a? Numeric
          os_surface.setViewFactortoGround(@hash[:boundary_condition][:view_factor])
        else
          os_surface.autocalculateViewFactortoGround
        end
      when 'Surface'
        # get adjacent surface by identifier from openstudio model
        adj_srf_identifier = @hash[:boundary_condition][:boundary_condition_objects][0]
        surface_object = openstudio_model.getSurfaceByName(adj_srf_identifier)
        unless surface_object.empty?
          surface = surface_object.get
          os_surface.setAdjacentSurface(surface)
        end
      when 'OtherSideTemperature'
        srf_prop = OpenStudio::Model::SurfacePropertyOtherSideCoefficients.new(openstudio_model)
        srf_prop.setName(@hash[:identifier] + '_OtherTemp')
        if @hash[:boundary_condition][:heat_transfer_coefficient].is_a? Numeric
          srf_prop.setCombinedConvectiveRadiativeFilmCoefficient(
            @hash[:boundary_condition][:heat_transfer_coefficient])
        else
          srf_prop.setCombinedConvectiveRadiativeFilmCoefficient(0)
        end
        if @hash[:boundary_condition][:temperature].is_a? Numeric
          srf_prop.setConstantTemperature(@hash[:boundary_condition][:temperature])
          srf_prop.setConstantTemperatureCoefficient(1)
          srf_prop.setExternalDryBulbTemperatureCoefficient(0)
        else
          srf_prop.setConstantTemperatureCoefficient(0)
          srf_prop.setExternalDryBulbTemperatureCoefficient(1)
        end
        os_surface.setSurfacePropertyOtherSideCoefficients(srf_prop)
      end

      unless boundary_condition == 'Surface' || boundary_condition == 'OtherSideTemperature'
        os_surface.setOutsideBoundaryCondition(boundary_condition)
      end

      # assign apertures if they exist
      if @hash[:apertures]
        @hash[:apertures].each do |aperture|
          ladybug_aperture = Aperture.new(aperture)
          os_subsurface_apertures = ladybug_aperture.to_openstudio(openstudio_model)
          os_subsurface_apertures.each do |os_subsurface_aperture|
            if @hash[:face_type] == 'RoofCeiling' or @hash[:face_type]  == 'Floor'
              if @hash[:boundary_condition][:type] == 'Outdoors' && aperture[:is_operable] == false
                os_subsurface_aperture.setSubSurfaceType('Skylight')
              end
            end
            os_subsurface_aperture.setSurface(os_surface)
          end
        end
      end

      # assign doors if they exist
      if @hash[:doors]
        @hash[:doors].each do |door|
          honeybee_door = Door.new(door)
          os_subsurface_doors = honeybee_door.to_openstudio(openstudio_model)
          os_subsurface_doors.each do |os_subsurface_door|
            os_subsurface_door.setSurface(os_surface)
            if door[:is_glass] == true
              os_subsurface_door.setSubSurfaceType('GlassDoor')
            elsif (@hash[:face_type] == 'RoofCeiling' or @hash[:face_type] == 'Floor') && @hash[:boundary_condition][:type] == 'Outdoors'
              os_subsurface_door.setSubSurfaceType('OverheadDoor')
            elsif door[:is_glass] == false or door[:is_glass].nil?
              os_subsurface_door.setSubSurfaceType('Door')
            end
          end
        end
      end

      os_surface.subSurfaces.each do |os_subsurface|
        if os_subsurface.hasAdditionalProperties
          adj_sub_srf_identifier = os_subsurface.additionalProperties.getFeatureAsString("AdjacentSubSurfaceName")
          unless adj_sub_srf_identifier.empty?
            adj_sub_srf = openstudio_model.getSubSurfaceByName(adj_sub_srf_identifier.get)
            unless adj_sub_srf.empty?
              os_subsurface.setAdjacentSubSurface(adj_sub_srf.get)
            end
          end

          # clean up, we don't need this object any more
          os_subsurface.removeAdditionalProperties
        end
      end

      os_surface
    end

    def to_openstudio_shade(openstudio_model, shading_surface_group)
      # get the vertices from the face
      if @hash[:geometry][:vertices].nil?
        hb_verts = @hash[:geometry][:boundary]
      else
        hb_verts = @hash[:geometry][:vertices]
      end

      # create the openstudio shading surface
      os_vertices = OpenStudio::Point3dVector.new
      hb_verts.each do |vertex|
        os_vertices << OpenStudio::Point3d.new(vertex[0], vertex[1], vertex[2])
      end

      os_shading_surface = OpenStudio::Model::ShadingSurface.new(os_vertices, openstudio_model)
      os_shading_surface.setName(@hash[:identifier])
      unless @hash[:display_name].nil?
        os_shading_surface.setDisplayName(@hash[:display_name])
      end

      # get the approriate construction id
      construction_id = nil
      if @hash[:properties].key?(:energy) && @hash[:properties][:energy][:construction]
        construction_id = @hash[:properties][:energy][:construction]
      elsif @hash[:face_type] == 'Wall'
        construction_id = 'Generic Exterior Wall'
      elsif @hash[:face_type] == 'RoofCeiling'
        construction_id = 'Generic Roof'
      elsif @hash[:face_type] == 'Floor'
        construction_id = 'Generic Exposed Floor'
      end
  
      # assign the construction
      unless construction_id.nil?
        construction = openstudio_model.getConstructionByName(construction_id)
        unless construction.empty?
          os_construction = construction.get
          os_shading_surface.setConstruction(os_construction)
        end
      end

      # add the shade to the group
      os_shading_surface.setShadingSurfaceGroup(shading_surface_group)

      # convert the apertures to shade objects
      if @hash[:apertures]
        @hash[:apertures].each do |aperture|
          hb_aperture = Aperture.new(aperture)
          os_subsurface_aperture = hb_aperture.to_openstudio_shade(openstudio_model, shading_surface_group)
        end
      end

      # convert the apertures to shade objects
      if @hash[:doors]
        @hash[:doors].each do |door|
          hb_door = Door.new(door)
          os_subsurface_door = hb_door.to_openstudio_shade(openstudio_model, shading_surface_group)
        end
      end

      os_shading_surface
    end

  end # Face
end # Honeybee

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
      # reorder the vertices to ensure they start from the upper-left corner
      os_vertices = OpenStudio::Point3dVector.new
      @hash[:geometry][:boundary].each do |vertex|
        os_vertices << OpenStudio::Point3d.new(vertex[0], vertex[1], vertex[2])
      end
      reordered_vertices = OpenStudio.reorderULC(os_vertices)

      # create the openstudio surface and assign the type
      os_surface = OpenStudio::Model::Surface.new(reordered_vertices, openstudio_model)
      os_surface.setName(@hash[:identifier])
      os_surface.setSurfaceType(@hash[:face_type])

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

      # assign the boundary condition
      boundary_condition = (@hash[:boundary_condition][:type])
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
      end
      unless @hash[:boundary_condition][:type] == 'Surface'
        os_surface.setOutsideBoundaryCondition(@hash[:boundary_condition][:type])
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
  end # Face
end # Honeybee

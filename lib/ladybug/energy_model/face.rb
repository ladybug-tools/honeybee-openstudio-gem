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
require 'ladybug/energy_model/aperture'

require 'json-schema'
require 'json'
require 'openstudio'

module Ladybug
  module EnergyModel
    class Face < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'Face'
      end

      def defaults
        result = {}
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        model_surf = openstudio_model.getSurfaceByName(@hash[:name])
        return model_surf.get unless model_surf.empty?
        nil
      end

      def create_openstudio_object(openstudio_model)       
        openstudio_vertices = OpenStudio::Point3dVector.new
        @hash[:geometry][:boundary].each do |vertex|
          openstudio_vertices << OpenStudio::Point3d.new(vertex[0], vertex[1], vertex[2])
        end

        openstudio_construction = nil
        if @hash[:properties][:energy][:construction]
          construction_name = @hash[:properties][:energy][:construction]
          construction = openstudio_model.getConstructionByName(construction_name)
          unless construction.empty?
            openstudio_construction = construction.get
          end
        end

        openstudio_surface = OpenStudio::Model::Surface.new(openstudio_vertices, openstudio_model)
        openstudio_surface.setName(@hash[:name])
        openstudio_surface.setSurfaceType(@hash[:face_type])
        openstudio_surface.setConstruction(openstudio_construction) if openstudio_construction
        boundary_condition = (@hash[:boundary_condition][:type])
       
        case boundary_condition
        when 'Outdoors'
          if @hash[:boundary_condition][:sun_exposure] == true
            openstudio_surface.setSunExposure('SunExposed')
          else 
            openstudio_surface.setSunExposure('NoSun')
          end
          if @hash[:boundary_condition][:wind_exposure] == true
            openstudio_surface.setWindExposure('WindExposed')
          else
            openstudio_surface.setWindExposure('NoWind')
          end
          if @hash[:boundary_condition][:view_factor] == 'autocalculate'
            openstudio_surface.autocalculateViewFactortoGround
          else
            openstudio_surface.setViewFactortoGround(@hash[:boundary_condition][:view_factor])
          end
        when 'Surface'
          if @hash[:boundary_condition][:boundary_condition_objects][0]
            surface = nil
            surface_object = openstudio_model.getSurfaceByName(@hash[:boundary_condition][:boundary_condition_objects][0])
            unless surface_object.empty?
              surface = surface_object.get
              openstudio_surface.setAdjacentSurface(surface)
            end
          end
                   
          #key = @hash
          #value = @hash[:boundary_condition][:boundary_condition_objects][0]
          
          #$surfaces.store(:key, value)

          #$surfaces.merge!(key: value)

          puts "#{$surfaces}"
        end

        openstudio_surface.setOutsideBoundaryCondition(@hash[:boundary_condition][:type]) unless @hash[:boundary_condition][:type] == 'Surface'

        if @hash[:apertures]
          @hash[:apertures].each do |aperture|
            aperture = Aperture.new(aperture)
            openstudio_subsurface_aperture = aperture.to_openstudio(openstudio_model)
            if @hash[:face_type] == 'RoofCeiling' or @hash[:face_type]  == 'Floor' && @hash[:boundary_condition][:type] == 'Outdoors' && aperture[:is_operable] == false
              openstudio_subsurface_aperture.setSubSurfaceType('Skylight')
            end
            openstudio_subsurface_aperture.setSurface(openstudio_surface)
          end
        end

        if @hash[:doors]
          @hash[:doors].each do |door|
            door = Door.new(door)
            openstudio_subsurface_door = door.to_openstudio(openstudio_model)
            if @hash[:face_type] == 'RoofCeiling' or @hash[:face_type] == 'Floor' && @hash[:boundary_condition][:type] == 'Outdoors'
              openstudio_subsurface_aperture.setSubSurfaceType('OverheadDoor')
            end
            openstudio_subsurface_door.setSurface(openstudio_surface)
          end
        end

        openstudio_shading_surface_group = OpenStudio::Model::ShadingSurfaceGroup.new(openstudio_model)
        
        if @hash[:outdoor_shades]
          @hash[:outdoor_shades].each do |outdoor_shade|
            outdoor_shade = Shade.new(outdoor_shade)
            openstudio_outdoor_shade = outdoor_shade.to_openstudio(openstudio_model) 
            openstudio_shading_surface_group.setShadedSurface(openstudio_surface)
            openstudio_outdoor_shade.setShadingSurfaceGroup(openstudio_shading_surface_group)
          end
        end
        
        openstudio_surface
      end
    end # Face
  end # EnergyModel
end # Ladybug

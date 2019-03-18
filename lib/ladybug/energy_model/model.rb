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

require 'ladybug/energy_model/extension'

require 'json-schema'
require 'json'
require 'openstudio'

module Ladybug
  module EnergyModel
    class Model
      attr_reader :errors, :warnings
    
      # Read Ladybug Energy Model JSON from disk
      def initialize(file)
        # initialize class variable @@extension only once
        @@extension ||= Extension.new
        @@schema ||= @@extension.schema

        @file = file
        @model = nil
        File.open(File.join(file), 'r') do |f|
          @model = JSON::parse(f.read, {symbolize_names: true})
        end
        
        @model_type = @model[:type]
        raise 'Unknown model type' if @model_type.nil?
        
        @face_by_face = false
        if @model[:type] == 'FaceByFaceModel'
          @face_by_face = true
        elsif @model[:type] == 'Model'
          # no-op
        else
          raise "Unknown model type '#{@model[:type]}'"
        end
      end
      
      # check if the model is valid
      def valid?
        return JSON::Validator.validate(@model, @@schema, {:fragment => "#/components/schemas/#{@model_type}"})
      end
      
      # return detailed model validation errors
      def validation_errors
        return JSON::Validator.fully_validate(@model, @@schema, {:fragment => "#/components/schemas/#{@model_type}"})
      end
      
      # convert to a new openstudio model
      def to_openstudio
        osm = OpenStudio::Model::Model.new
        create_openstudio_objects(osm)
        return osm
      end
      
      # create openstudio objects in the given osm, clears errors and warnings
      def create_openstudio_objects(osm)
        @errors = []
        @warnings = []
        
        create_faces(osm)
      end
      
      def create_faces(osm)
        @model[:faces].each do |face|
          name = face[:name]
          face_type = face[:face_type]
          parent = face[:parent]
          
          # for now make parent a space, check if should be a zone?
          space = osm.getSpaceByName(parent)
          if space.empty?
            space = OpenStudio::Model::Space.new(osm)
            space.setName(parent)
          else
            space = space.get
          end
          
          surface_type = nil
          air_wall = false
          case face_type  # 0 = Wall, 1 = RoofCeiling, 2 = Floor, 3 = AirWall\n",
          when 0
            surface_type = 'Wall' 
          when 1
            surface_type = 'RoofCeiling' 
          when 2
            surface_type = 'Floor' 
          when 3
            air_wall = true          
          else
            @errors << "Unknown face_type '#{face_type}' for face '#{name}', surface not created"
            next
          end
          
          vertices = OpenStudio::Point3dVector.new
          if @face_by_face
            # vertices in face
            face[:vertices].each do |v|
              vertices << OpenStudio::Point3d.new(v[0], v[1], v[2])
            end 
          else
            # vertices in separate list
            face[:vertices].each do |vi|
              v = @model[:vertices][vi]
              vertices << OpenStudio::Point3d.new(v[0], v[1], v[2])
            end 
          end
               
          surface = OpenStudio::Model::Surface.new(vertices, osm)
          surface.setName(name)
          surface.setSpace(space)
          surface.setSurfaceType(surface_type) if surface_type
          if air_wall
            # DLM: todo
          end
        end
      end
      
      def create_apertures(osm)
      end
      
      
    end # Model
  end # EnergyModel
end # Ladybug

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

require 'json-schema'
require 'json'
require 'openstudio'

module Ladybug
  module EnergyModel      
    class Face < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash)
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'Face'
      end
      
      private
      
      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getSurfaceByName(@hash[:name]) #check
        if object.is_initialized
          return object.get
        end
        return nil
      end
      
      def create_openstudio_object(openstudio_model)
        openstudio_surface = OpenStudio::Model::Surface.new(openstudio_model)
        openstudio_surface.setName(@hash[:name])
        @hash[:face].each do |face| #check
          name = face[:name]
          face_type = face[:face_type]
          rad_modifier = face[:rad_modifier]
          rad_modifier_dir = face[:rad_modifier_dir]
          energy_construction_opaque = face[:energy_construction_opaque]
          energy_construction_transparent = face[:energy_construction_transparent]
          face_object = nil

          case face_type
          when "Wall"
            face_object = "Wall"
          when "RoofCeiling"
            face_object = "RoofCeiling"
          when "Floor"
            face_object = "Floor"
          when "AirWall"
            face_object = "AirWall"
          when "Shading"
            face_object = "Shading"
          else
            raise "Unknown face_type #{face_type} for face #{name}."
        end
        
        openstudio_surfaces = face_object.to_openstudio(openstudio_model)
        openstudio_surface << openstudio_surfaces
      end

        return openstudio_surface
      end

    end # Face
  end # EnergyModel
end # Ladybug

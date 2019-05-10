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

require 'ladybug/construction/extension'

require 'json-schema'
require 'json'
require 'openstudio'

module Ladybug
  module EnergyModel      
    class Construction
      attr_reader :errors, :warnings

      def initialize(hash)
        @@extension ||=Extension.new
        @@schema ||=@@extension.schema

        @file = file 
        @construction = hash
    
        @construction_type = @construction[:type]
        raise 'Unknown construction type' if @construction_type.nil?

        @opaque = false
        if @model[:type] == 'EnergyConstructionOpaque'
          @opaque = true
        elsif @model[:type] == 'EnergyConstructionTransparent'
          @transparent = true
        else 
          raise "Unknown construction type #{@model[:type]}"
        end  
      end

      def valid?
        return JSON::Validator.validate(@construction, @@schema)


      def validation_errors
        return JSON::Validator.fully_validate(@construction, @@schema)
      end 
    
      def to_openstudio
        osm = OpenStudio::model::Construction.new
        create_openstudio_objects(osm)
        return osm
      end

      def create_openstudio_objects(osm)
        @errors = []
        @warnings = []
        create_construction(osm)
      end

      def create_construction(osm)
        @construction[:materials].each do |materials|
          name = materials[:name]
          material_type = materials[:material_type]
      end

      opaque_material = OpenStudio::OpaqueMaterial.new


      fenestration_material = OpenStudio::FenestrationMaterial.new 

    end
  end
end

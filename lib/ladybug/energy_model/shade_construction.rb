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

require "#{File.dirname(__FILE__)}/model_object"



require 'openstudio'

module Ladybug
  module EnergyModel
    class ShadeConstruction < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)
      end

      def defaults
        result = {}
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getConstructionByName(@hash[:name])
        return object.get if object.is_initialized
        nil
      end

      def create_openstudio_object(openstudio_model)

        openstudio_construction = OpenStudio::Model::Construction.new(openstudio_model)
        openstudio_construction.setName(@hash[:name])
        openstudio_materials = OpenStudio::Model::MaterialVector.new

        if @hash[:is_specular] == true
          openstudio_material = OpenStudio::Model::StandardGlazing.new(openstudio_model)
          if @hash[:solar_reflectance]
            openstudio_material.setFrontSideSolarReflectanceatNormalIncidence(@hash[:solar_reflectance])
          else
            openstudio_material.setFrontSideSolarReflectanceatNormalIncidence(@@schema[:definitions][:ShadeConstruction][:properties][:solar_reflectance][:default].to_f)
          end
          if @hash[:visible_reflectance]
            openstudio_material.setFrontSideVisibleReflectanceatNormalIncidence(@hash[:visible_reflectance].to_f)
          else
            openstudio_material.setFrontSideVisibleReflectanceatNormalIncidence(@@schema[:definitions][:ShadeConstruction][:properties][:solar_reflectance][:default].to_f)
          end
        else
          openstudio_material = OpenStudio::Model::StandardOpaqueMaterial.new(openstudio_model)
          if @hash[:solar_reflectance]
            openstudio_material.setSolarReflectance(OpenStudio::OptionalDouble.new(@hash[:solar_reflectance]))
          else 
            openstudio_material.setSolarReflectance(OpenStudio::OptionalDouble.new(@@schema[:definitions][:ShadeConstruction][:properties][:visible_reflectance][:default]))
          end
          if @hash[:visible_reflectance]
            openstudio_material.setVisibleReflectance(OpenStudio::OptionalDouble.new(@hash[:visible_reflectance]))
          else 
            openstudio_material.setVisibleReflectance(OpenStudio::OptionalDouble.new(@@schema[:definitions][:ShadeConstruction][:properties][:solar_reflectance][:default]))
          end
          openstudio_material.setSpecificHeat(100) #Bug in OpenStudio default Specific Heat is 0.1.
        end
        
        openstudio_materials << openstudio_material
        openstudio_construction.setLayers(openstudio_materials)
        openstudio_construction
      
      end

    end #ShadeConstruction
  end #EnergyModel
end #Ladybug
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

require 'from_honeybee/model_object'

require 'openstudio'

module FromHoneybee
  class ShadeConstruction < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
    end

    def defaults
      @@schema[:components][:schemas][:ShadeConstruction][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getConstructionByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      
      os_construction = OpenStudio::Model::Construction.new(openstudio_model)
      os_construction.setName(@hash[:identifier])
      os_materials = OpenStudio::Model::MaterialVector.new

      # create standard glazing if is specular is true
      if @hash[:is_specular] == true
        os_material = OpenStudio::Model::StandardGlazing.new(openstudio_model)
        
        # assign solar reflectance
        if @hash[:solar_reflectance]
          os_material.setFrontSideSolarReflectanceatNormalIncidence(@hash[:solar_reflectance])
        else
          os_material.setFrontSideSolarReflectanceatNormalIncidence(defaults[:solar_reflectance][:default])
        end
        
        # assign visible reflectance
        if @hash[:visible_reflectance]
          os_material.setFrontSideVisibleReflectanceatNormalIncidence(@hash[:visible_reflectance])
        else
          os_material.setFrontSideVisibleReflectanceatNormalIncidence(defaults[:solar_reflectance][:default])
        end

      # create standard opaque material if is specular is false  
      else
        os_material = OpenStudio::Model::StandardOpaqueMaterial.new(openstudio_model)
        
        # assign solar reflectance
        if @hash[:solar_reflectance]
          os_material.setSolarReflectance(OpenStudio::OptionalDouble.new(@hash[:solar_reflectance]))
        else 
          os_material.setSolarReflectance(OpenStudio::OptionalDouble.new(defaults[:visible_reflectance][:default]))
        end
        
        # assign visible reflectance
        if @hash[:visible_reflectance]
          os_material.setVisibleReflectance(OpenStudio::OptionalDouble.new(@hash[:visible_reflectance]))
        else 
          os_material.setVisibleReflectance(OpenStudio::OptionalDouble.new(defaults[:solar_reflectance][:default]))
        end
        
        # assign specific heat
        os_material.setSpecificHeat(100)  # bug in OpenStudio default Specific Heat is 0.1.
      end
      
      # add materials and set layers to construction
      os_materials << os_material
      os_construction.setLayers(os_materials)
      os_construction
    
    end

  end #ShadeConstruction
end #FromHoneybee
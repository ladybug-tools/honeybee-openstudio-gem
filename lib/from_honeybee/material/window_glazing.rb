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
  class EnergyWindowMaterialGlazing < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
    end

    def defaults
      @@schema[:components][:schemas][:EnergyWindowMaterialGlazing][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getStandardGlazingByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create openstudio standard glazing object and set identifier
      os_glazing = OpenStudio::Model::StandardGlazing.new(openstudio_model)
      os_glazing.setName(@hash[:identifier])
      
      # assign thickness
      if @hash[:thickness]
        os_glazing.setThickness(@hash[:thickness])
      else
        os_glazing.setThickness(defaults[:thickness][:default])
      end
      
      # assign solar transmittance
      if @hash[:solar_transmittance]
        os_glazing.setSolarTransmittanceatNormalIncidence(@hash[:solar_transmittance])
      else
        os_glazing.setSolarTransmittanceatNormalIncidence(
          defaults[:solar_transmittance][:default])
      end
      
      # assign front solar reflectance
      if @hash[:solar_reflectance]
        os_glazing.setFrontSideSolarReflectanceatNormalIncidence(@hash[:solar_reflectance])
      else
        os_glazing.setFrontSideSolarReflectanceatNormalIncidence(
          defaults[:solar_reflectance][:default])
      end
      
      # assign back solar reflectance
      if @hash[:solar_reflectance_back]
        os_glazing.setBackSideSolarReflectanceatNormalIncidence(@hash[:solar_reflectance_back])
      else
        os_glazing.setBackSideSolarReflectanceatNormalIncidence(
          defaults[:solar_reflectance_back][:default])
      end
      
      # assign visible transmittance at normal incidence
      if @hash[:visible_transmittance]
        os_glazing.setVisibleTransmittanceatNormalIncidence(@hash[:visible_transmittance])
      else
        os_glazing.setVisibleTransmittanceatNormalIncidence(
          defaults[:visible_transmittance][:default])
      end
      
      # assign front side visible reflectance
      if @hash[:visible_reflectance]
        os_glazing.setFrontSideVisibleReflectanceatNormalIncidence(@hash[:visible_reflectance])
      else
        os_glazing.setFrontSideVisibleReflectanceatNormalIncidence(
          defaults[:visible_reflectance][:default])
      end
      
      # assign back side visible reflectance
      if @hash[:visible_reflectance_back]
        os_glazing.setBackSideVisibleReflectanceatNormalIncidence(@hash[:visible_reflectance_back])
      else
        os_glazing.setBackSideVisibleReflectanceatNormalIncidence(
          defaults[:visible_reflectance_back][:default])
      end
      
      # assign infrared transmittance
      if @hash[:infrared_transmittance]
        os_glazing.setInfraredTransmittanceatNormalIncidence(@hash[:infrared_transmittance])
      else
        os_glazing.setInfraredTransmittanceatNormalIncidence(
          defaults[:infrared_transmittance][:default])
      end
      
      # assign front side emissivity 
      if @hash[:emissivity]
        os_glazing.setFrontSideInfraredHemisphericalEmissivity(@hash[:emissivity])
      else
        os_glazing.setFrontSideInfraredHemisphericalEmissivity(
          defaults[:emissivity][:default])
      end
      
      # assign back side emissivity
      if @hash[:emissivity_back]
        os_glazing.setBackSideInfraredHemisphericalEmissivity(@hash[:emissivity_back])
      else
        os_glazing.setBackSideInfraredHemisphericalEmissivity(
          defaults[:emissivity_back][:default])
      end
      
      # assign conductivity
      if @hash[:conductivity]
        os_glazing.setThermalConductivity(@hash[:conductivity])
      else
        os_glazing.setThermalConductivity(
          defaults[:conductivity_glass][:default])
      end
      
      # assign dirt correction
      if @hash[:dirt_correction]
        os_glazing.setDirtCorrectionFactorforSolarandVisibleTransmittance(@hash[:dirt_correction])
      else
        os_glazing.setDirtCorrectionFactorforSolarandVisibleTransmittance(
          defaults[:dirt_correction][:default])
      end
      
      # assign solar diffusing
      if @hash[:solar_diffusing] == false
        os_glazing.setSolarDiffusing(false)
      elsif @hash[:solar_diffusing] == true
        os_glazing.setSolarDiffusing(true)
      else
        os_glazing.setSolarDiffusing(defaults[:solar_diffusing][:default])
      end

      os_glazing
    end
  end # EnergyWindowMaterialGlazing
end # FromHoneybee

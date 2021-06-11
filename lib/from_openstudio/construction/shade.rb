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

require 'honeybee/construction/shade'
require 'from_openstudio/model_object'

module Honeybee
  class ShadeConstruction < ModelObject

    def self.from_construction(construction)
        # create an empty hash
        hash = {}
        hash[:type] = 'ShadeConstruction'
        # set hash values from OpenStudio Object
        hash[:identifier] = construction.nameString
        # get outermost construction layers
        layer = construction.layers[0]
        if layer.to_StandardGlazing.is_initialized
          layer = layer.to_StandardGlazing.get
          hash[:is_specular] = true
          # set reflectance properties from outermost layer
          unless layer.frontSideSolarReflectanceatNormalIncidence.empty?
            hash[:solar_reflectance] = layer.frontSideSolarReflectanceatNormalIncidence.get
          end
          unless layer.frontSideVisibleReflectanceatNormalIncidence.empty?
            hash[:visible_reflectance] = layer.frontSideVisibleReflectanceatNormalIncidence.get
          end
        elsif layer.to_StandardOpaqueMaterial.is_initialized
          layer = layer.to_StandardOpaqueMaterial.get
          hash[:is_specular] = false
          # set reflectance properties from outermost layer
          unless layer.solarReflectance.empty?
            hash[:solar_reflectance] = layer.solarReflectance.get
          end
          unless layer.visibleReflectance.empty?
            hash[:visible_reflectance] = layer.visibleReflectance
          end
        elsif layer.to_MasslessOpaqueMaterial.is_initialized
          layer = layer.to_MasslessOpaqueMaterial.get
          hash[:is_specular] = false
          # set reflectance properties from outermost layer
          unless layer.solarAbsorptance.empty?
            hash[:solar_reflectance] = 1 - layer.solarAbsorptance.get
          end
          unless layer.visibleAbsorptance.empty?
            hash[:visible_reflectance] = 1 - layer.visibleAbsorptance.get
          end
        end

        hash
    end

  end # ShadeConstruction
end # Honeybee

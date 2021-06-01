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
        hash[:materials] = []
        # get construction layers
        layers = construction.layers
        i = 0
        layers.each do |layer|
          i += 1
          hash[:materials] << layer.nameString
          if layer.to_StandardGlazing.is_initialized
            hash[:is_specular] = true
            # get outermost layer and set reflectance properties
            if i == 1
              unless layer.frontSideSolarReflectanceatNormalIncidence.empty?
                hash[:solar_reflectance] = layer.frontSideSolarReflectanceatNormalIncidence.get
              end
              unless layer.frontSideVisibleReflectanceatNormalIncidence.empty?
                hash[:visible_reflectance] = layer.frontSideVisibleReflectanceatNormalIncidence.get
              end
            end
          elsif layer.to_StandardOpaqueMaterial.is_initialized
            hash[:is_specular] = false
            # get outermost layer and set reflectance properties
            if i == 1
                #TODO: these properties were giving an OS error
                hash[:solar_reflectance] = layer.solarReflectance
                hash[:visible_reflectance] = layer.visibleReflectance
            end
          end
        end

        hash
    end

  end # ShadeConstruction
end # Honeybee

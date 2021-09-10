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

require 'honeybee/material/window_glazing'
require 'to_openstudio/model_object'

module Honeybee
  class EnergyWindowMaterialGlazing

    def self.from_material(material)
        # create an empty hash
        hash = {}
        hash[:type] = 'EnergyWindowMaterialGlazing'
        # set hash values from OpenStudio Object
        hash[:identifier] = clean_name(material.nameString)
        hash[:thickness] = material.thickness
        hash[:solar_transmittance] = material.solarTransmittance
        # check if boost optional object is empty
        unless material.frontSideSolarReflectanceatNormalIncidence.empty?
            hash[:solar_reflectance] = material.frontSideSolarReflectanceatNormalIncidence.get
        end
        # check if boost optional object is empty
        unless material.backSideSolarReflectanceatNormalIncidence.empty?
            hash[:solar_reflectance_back] = material.backSideSolarReflectanceatNormalIncidence.get
        end
        # check if boost optional object is empty
        unless material.visibleTransmittanceatNormalIncidence.empty?
            hash[:visible_transmittance] = material.visibleTransmittanceatNormalIncidence.get
        end
        # check if boost optional object is empty
        unless material.frontSideVisibleReflectanceatNormalIncidence.empty?
            hash[:visible_reflectance] = material.frontSideVisibleReflectanceatNormalIncidence.get
        end
        # check if boost optional object is empty
        unless material.backSideVisibleReflectanceatNormalIncidence.empty?
            hash[:visible_reflectance_back] = material.backSideVisibleReflectanceatNormalIncidence.get
        end
        hash[:infrared_transmittance] = material.infraredTransmittance
        hash[:emissivity] = material.frontSideInfraredHemisphericalEmissivity
        hash[:emissivity_back] = material.backSideInfraredHemisphericalEmissivity
        hash[:conductivity] = material.thermalConductivity
        hash[:dirt_correction] = material.dirtCorrectionFactorforSolarandVisibleTransmittance
        hash[:solar_diffusing] = material.solarDiffusing

        hash
    end

  end # EnergyWindowMaterialGlazing
end # Honeybee

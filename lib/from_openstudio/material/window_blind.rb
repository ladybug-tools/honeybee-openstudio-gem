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

require 'honeybee/material/window_blind'
require 'to_openstudio/model_object'

module Honeybee
  class EnergyWindowMaterialBlind

    def self.from_material(material)
        # create an empty hash
        hash = {}
        hash[:type] = 'EnergyWindowMaterialBlind'
        # set hash values from OpenStudio Object
        hash[:identifier] = material.nameString
        hash[:slat_orientation] = material.slatOrientation
        hash[:slat_width] = material.slatWidth
        hash[:slat_separation] = material.slatSeparation
        hash[:slat_thickness] = material.slatThickness
        hash[:slat_width] = material.slatWidth
        hash[:slat_angle] = material.slatAngle
        hash[:slat_conductivity] = material.slatConductivity
        hash[:beam_solar_transmittance] = material.slatBeamSolarTransmittance
        hash[:beam_solar_reflectance] = material.frontSideSlatBeamSolarReflectance
        hash[:beam_solar_reflectance_back] = material.backSideSlatBeamSolarReflectance
        hash[:diffuse_solar_reflectance] = material.frontSideSlatDiffuseSolarReflectance
        hash[:diffuse_solar_reflectance_back] = material.backSideSlatDiffuseSolarReflectance
        hash[:diffuse_visible_transmittance] = material.slatDiffuseVisibleTransmittance
        # check if boost optional object is empty
        unless material.frontSideSlatDiffuseVisibleReflectance.nil?
            hash[:diffuse_visible_reflectance] = material.frontSideSlatDiffuseVisibleReflectance.get
        end
        # check if boost optional object is empty
        unless material.backSideSlatDiffuseVisibleReflectance.nil?
            hash[:diffuse_visible_reflectance_back] = material.backSideSlatDiffuseVisibleReflectance.get
        end
        hash[:infrared_transmittance] = material.slatInfraredHemisphericalTransmittance
        hash[:emissivity] = material.frontSideSlatInfraredHemisphericalEmissivity
        hash[:emissivity_back] = material.backSideSlatInfraredHemisphericalEmissivity
        hash[:distance_to_glass] = material.blindtoGlassDistance
        hash[:top_opening_multiplier] = material.blindTopOpeningMultiplier
        hash[:bottom_opening_multiplier] = material.blindBottomOpeningMultiplier
        hash[:left_opening_multiplier] = material.blindLeftSideOpeningMultiplier
        hash[:right_opening_multiplier] = material.blindRightSideOpeningMultiplier

        hash
    end

  end # EnergyWindowMaterialBlind
end # Honeybee

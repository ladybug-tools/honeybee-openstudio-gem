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

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getBlindByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create blind OpenStudio object
      os_blind = OpenStudio::Model::Blind.new(openstudio_model)
      os_blind.setName(@hash[:identifier])

      # assign slat orientation
      if @hash[:slat_orientation]
        os_blind.setSlatOrientation(@hash[:slat_orientation])
      else
        os_blind.setSlatOrientation(defaults[:slat_orientation][:default])
      end

      # assign slat width
      if @hash[:slat_width]
        os_blind.setSlatWidth(@hash[:slat_width])
      else
        os_blind.setSlatWidth(defaults[:slat_width][:default])
      end

      # assign slat separation if it exists
      if @hash[:slat_separation]
        os_blind.setSlatSeparation(@hash[:slat_separation])
      else
        os_blind.setSlatSeparation(defaults[:slat_separation][:default])
      end

      # assign slat thickness if it exists
      if @hash[:slat_thickness]
        os_blind.setSlatThickness(@hash[:slat_thickness])
      else
        os_blind.setSlatThickness(defaults[:slat_thickness][:default])
      end

      # assign slat angle if it exists
      if @hash[:slat_angle]
        os_blind.setSlatAngle(@hash[:slat_angle])
      else
        os_blind.setSlatAngle(defaults[:slat_angle][:default])
      end

      # assign slat conductivity if it exists
      if @hash[:slat_conductivity]
        os_blind.setSlatConductivity(@hash[:slat_conductivity])
      else
        os_blind.setSlatConductivity(defaults[:slat_conductivity][:default])
      end

      # assign beam solar transmittance if it exists
      if @hash[:beam_solar_transmittance]
        os_blind.setSlatBeamSolarTransmittance(@hash[:beam_solar_transmittance])
      else
        os_blind.setSlatBeamSolarTransmittance(defaults[:beam_solar_transmittance][:default])
      end

      # assign beam solar reflectance front if it exists
      if @hash[:beam_solar_reflectance]
        os_blind.setFrontSideSlatBeamSolarReflectance(@hash[:beam_solar_reflectance])
      else
        os_blind.setFrontSideSlatBeamSolarReflectance(
          defaults[:beam_solar_reflectance][:default])
      end

      # assign beam solar reflectance back
      if @hash[:beam_solar_reflectance_back]
        os_blind.setBackSideSlatBeamSolarReflectance(@hash[:beam_solar_reflectance_back])
      else
        os_blind.setBackSideSlatBeamSolarReflectance(
          defaults[:beam_solar_reflectance_back][:default])
      end

      # assign diffuse solar transmittance
      if @hash[:diffuse_solar_transmittance]
        os_blind.setSlatDiffuseSolarTransmittance(@hash[:diffuse_solar_transmittance])
      else
        os_blind.setSlatDiffuseSolarTransmittance(
          defaults[:diffuse_solar_transmittance][:default])
      end

      # assign front diffuse solar reflectance
      if @hash[:diffuse_solar_reflectance]
        os_blind.setFrontSideSlatDiffuseSolarReflectance(@hash[:diffuse_solar_reflectance])
      else
        os_blind.setFrontSideSlatDiffuseSolarReflectance(
          defaults[:diffuse_solar_reflectance][:default])
      end

      # assign back diffuse solar reflectance
      if @hash[:diffuse_solar_reflectance_back]
        os_blind.setBackSideSlatDiffuseSolarReflectance(@hash[:diffuse_solar_reflectance_back])
      else
        os_blind.setBackSideSlatDiffuseSolarReflectance(
          defaults[:diffuse_solar_reflectance_back][:default])
      end

      # assign front diffuse visible transmittance
      if @hash[:diffuse_visible_transmittance]
        os_blind.setSlatDiffuseVisibleTransmittance(@hash[:diffuse_visible_transmittance])
      else
        os_blind.setSlatDiffuseVisibleTransmittance(
          defaults[:diffuse_visible_transmittance][:default])
      end

      # assign front diffuse visible reflectance
      if @hash[:diffuse_visible_reflectance]
        os_blind.setFrontSideSlatDiffuseVisibleReflectance(@hash[:diffuse_visible_reflectance])
      else
        os_blind.setFrontSideSlatDiffuseVisibleReflectance(
          defaults[:diffuse_visible_reflectance][:default])
      end

      # assign back diffuse visible reflectance
      if @hash[:diffuse_visible_reflectance_back]
        os_blind.setBackSideSlatDiffuseVisibleReflectance(@hash[:diffuse_visible_reflectance_back])
      else
        os_blind.setBackSideSlatDiffuseVisibleReflectance(
          defaults[:diffuse_visible_reflectance_back][:default])
      end

      # assign front beam visible transmittance
      if @hash[:beam_visible_transmittance]
        os_blind.setSlatBeamVisibleTransmittance(@hash[:beam_visible_transmittance])
      else
        os_blind.setSlatBeamVisibleTransmittance(
          defaults[:beam_visible_transmittance][:default])
      end

      # assign front beam visible reflectance
      if @hash[:beam_visible_reflectance]
        os_blind.setFrontSideSlatBeamVisibleReflectance(@hash[:beam_visible_reflectance])
      else
        os_blind.setFrontSideSlatBeamVisibleReflectance(
          defaults[:beam_visible_reflectance][:default])
      end

      # assign back beam visible reflectance
      if @hash[:beam_visible_reflectance_back]
        os_blind.setBackSideSlatBeamVisibleReflectance(@hash[:beam_visible_reflectance_back])
      else
        os_blind.setBackSideSlatBeamVisibleReflectance(
          defaults[:beam_visible_reflectance_back][:default])
      end

      # assign infrared transmittance
      if @hash[:infrared_transmittance]
        os_blind.setSlatInfraredHemisphericalTransmittance(@hash[:infrared_transmittance])
      else
        os_blind.setSlatInfraredHemisphericalTransmittance(
          defaults[:infrared_transmittance][:default])
      end

      # assign front side emissivity
      if @hash[:emissivity]
        os_blind.setFrontSideSlatInfraredHemisphericalEmissivity(@hash[:emissivity])
      else
        os_blind.setFrontSideSlatInfraredHemisphericalEmissivity(
          defaults[:emissivity][:default])
      end

      # assign back side emissivity
      if @hash[:emissivity_back]
        os_blind.setBackSideSlatInfraredHemisphericalEmissivity(@hash[:emissivity_back])
      else
        os_blind.setBackSideSlatInfraredHemisphericalEmissivity(
          defaults[:emissivity_back][:default])
      end

      # assign distance to glass
      if @hash[:distance_to_glass]
        os_blind.setBlindtoGlassDistance(@hash[:distance_to_glass])
      else
        os_blind.setBlindtoGlassDistance(defaults[:distance_to_glass][:default])
      end

      # assign top opening multiplier
      if @hash[:top_opening_multiplier]
        os_blind.setBlindTopOpeningMultiplier(@hash[:top_opening_multiplier])
      else
        os_blind.setBlindTopOpeningMultiplier(
          defaults[:top_opening_multiplier][:default])
      end

      # assign bottom opening multiplier
      if @hash[:bottom_opening_multiplier]
        os_blind.setBlindBottomOpeningMultiplier(@hash[:bottom_opening_multiplier])
      else
        os_blind.setBlindBottomOpeningMultiplier(
          defaults[:bottom_opening_multiplier][:default])
      end

      # assign left opening multiplier
      if @hash[:left_opening_multiplier]
        os_blind.setBlindLeftSideOpeningMultiplier(@hash[:left_opening_multiplier])
      else
        os_blind.setBlindLeftSideOpeningMultiplier(
          defaults[:left_opening_multiplier][:default])
      end

      # assign right opening multiplier
      if @hash[:right_opening_multiplier]
        os_blind.setBlindRightSideOpeningMultiplier(@hash[:right_opening_multiplier])
      else
        os_blind.setBlindRightSideOpeningMultiplier(
          defaults[:right_opening_multiplier][:default])
      end

      os_blind
    end
  end # EnergyWindowMaterialBlind
end # Honeybee

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
    class EnergyWindowMaterialBlind < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'EnergyWindowMaterialBlind'
      end

      def defaults
        result = {}
        result[:type] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:type][:enum]
        result[:slat_width] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_width][:default].to_f
        result[:slat_separation] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_separation][:default].to_f
        result[:slat_thickness] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_thickness][:default].to_f
        result[:slat_angle] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_angle][:default].to_f
        result[:slat_conductivity] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_conductivity][:default].to_f
        result[:beam_solar_transmittance] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:beam_solar_transmittance][:default].to_f
        result[:beam_solar_reflectance] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:beam_solar_reflectance][:default].to_f
        result[:beam_solar_reflectance_back] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:beam_solar_reflectance_back][:default].to_f
        result[:diffuse_solar_transmittance] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_solar_transmittance][:default].to_f
        result[:diffuse_solar_reflectance] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_solar_reflectance][:default].to_f
        result[:diffuse_solar_reflectance_back] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_visible_reflectance_back][:default].to_f
        result[:infrared_hemispherical_transmittance] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:emissivity][:default].to_f
        result[:emissivity_back] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:emissivity_back][:default].to_f
        result[:distance_to_glass] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:distance_to_glass][:default].to_f
        result[:top_opening_multiplier] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:top_opening_multiplier][:default].to_f
        result[:bottom_opening_multiplier] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:bottom_opening_multiplier][:default].to_f
        result[:left_opening_multiplier] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:left_opening_multiplier][:default].to_f
        result[:right_opening_multiplier] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:right_opening_multiplier][:default].to_f
        result[:minimum_slat_angle] = @@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:maximum_slat_angle][:default]
        result
      end

      def name
        @hash[:name]
      end

      def name=(new_name)
        @hash[:name] = new_name
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getBlindByName(@hash[:name])
        return object.get if object.is_initialized
        nil
      end

      def create_openstudio_object(openstudio_model)
        openstudio_window_blind = OpenStudio::Model::Blind.new(openstudio_model)
        openstudio_window_blind.setName(@hash[:name])
        openstudio_window_blind.setSlatOrientation(@hash[:slat_orientation])
        if @hash[:slat_width]
          openstudio_window_blind.setSlatWidth(@hash[:slat_width].to_f)
        else
          openstudio_window_blind.setSlatWidth(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_width][:default].to_f)
        end
        if @hash[:slat_separation]
          openstudio_window_blind.setSlatSeparation(@hash[:slat_separation].to_f)
        else
          openstudio_window_blind.setSlatSeparation(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_separation][:default].to_f)
        end
        if @hash[:slat_thickness]
          openstudio_window_blind.setSlatThickness(@hash[:slat_thickness].to_f)
        else
          openstudio_window_blind.setSlatThickness(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_thickness][:default].to_f)
        end
        if @hash[:slat_angle]
          openstudio_window_blind.setSlatAngle(@hash[:slat_angle].to_f)
        else
          openstudio_window_blind.setSlatAngle(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_angle][:default].to_f)
        end
        if @hash[:slat_conductivity]
          openstudio_window_blind.setSlatConductivity(@hash[:slat_conductivity].to_f)
        else
          openstudio_window_blind.setSlatConductivity(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:slat_conductivity][:default].to_f)
        end
        if @hash[:beam_solar_transmittance]
          openstudio_window_blind.setSlatBeamSolarTransmittance(@hash[:beam_solar_transmittance].to_f)
        else
          openstudio_window_blind.setSlatBeamSolarTransmittance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:beam_solar_transmittance][:default].to_f)
        end
        if @hash[:beam_solar_reflectance]
          openstudio_window_blind.setFrontSideSlatBeamSolarReflectance(@hash[:beam_solar_reflectance].to_f)
        else
          openstudio_window_blind.setFrontSideSlatBeamSolarReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:beam_solar_reflectance][:default].to_f)
        end
        if @hash[:beam_solar_reflectance_back]
          openstudio_window_blind.setBackSideSlatBeamSolarReflectance(@hash[:beam_solar_reflectance_back].to_f)
        else
          openstudio_window_blind.setBackSideSlatBeamSolarReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:beam_solar_reflectance_back][:default].to_f)
        end
        if @hash[:diffuse_solar_transmittance]
          openstudio_window_blind.setSlatDiffuseSolarTransmittance(@hash[:diffuse_solar_transmittance].to_f)
        else
          openstudio_window_blind.setSlatDiffuseSolarTransmittance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_solar_transmittance][:default].to_f)
        end
        if @hash[:diffuse_solar_reflectance]
          openstudio_window_blind.setFrontSideSlatDiffuseSolarReflectance(@hash[:diffuse_solar_reflectance].to_f)
        else
          openstudio_window_blind.setFrontSideSlatDiffuseSolarReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_solar_reflectance][:default].to_f)
        end
        if @hash[:diffuse_solar_reflectance_back]
          openstudio_window_blind.setBackSideSlatDiffuseSolarReflectance(@hash[:diffuse_solar_reflectance_back].to_f)
        else
          openstudio_window_blind.setBackSideSlatDiffuseSolarReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_solar_reflectance_back][:default].to_f)
        end
        if @hash[:diffuse_visible_transmittance]
          openstudio_window_blind.setSlatDiffuseVisibleTransmittance(@hash[:diffuse_visible_transmittance].to_f)
        else
          openstudio_window_blind.setSlatDiffuseVisibleTransmittance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_visible_transmittance][:default].to_f)
        end
        if @hash[:diffuse_visible_reflectance]
          openstudio_window_blind.setFrontSideSlatDiffuseVisibleReflectance(@hash[:diffuse_visible_reflectance].to_f)
        else
          openstudio_window_blind.setFrontSideSlatDiffuseVisibleReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_visible_reflectance][:default].to_f)
        end
        if @hash[:diffuse_visible_reflectance_back]
          openstudio_window_blind.setBackSideSlatDiffuseVisibleReflectance(@hash[:diffuse_visible_reflectance_back].to_f)
        else
          openstudio_window_blind.setBackSideSlatDiffuseVisibleReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_visible_reflectance_back][:default].to_f)
        end
        if @hash[:infrared_transmittance]
          openstudio_window_blind.setSlatInfraredHemisphericalTransmittance(@hash[:infrared_transmittance].to_f)
        else
          openstudio_window_blind.setSlatInfraredHemisphericalTransmittance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:infrared_transmittance][:default].to_f)
        end
        if @hash[:emissivity]
          openstudio_window_blind.setFrontSideSlatInfraredHemisphericalEmissivity(@hash[:emissivity].to_f)
        else
          openstudio_window_blind.setFrontSideSlatInfraredHemisphericalEmissivity(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:emissivity][:default].to_f)
        end
        if @hash[:emissivity_back]
          openstudio_window_blind.setBackSideSlatInfraredHemisphericalEmissivity(@hash[:emissivity_back].to_f)
        else
          openstudio_window_blind.setBackSideSlatInfraredHemisphericalEmissivity(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:back_emissivity][:default].to_f)
        end
        if @hash[:distance_to_glass]
          openstudio_window_blind.setBlindtoGlassDistance(@hash[:distance_to_glass].to_f)
        else
          openstudio_window_blind.setBlindtoGlassDistance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:distance_to_glass][:default].to_f)
        end
        if @hash[:top_opening_multiplier]
          openstudio_window_blind.setBlindTopOpeningMultiplier(@hash[:top_opening_multiplier].to_f)
        else
          openstudio_window_blind.setBlindTopOpeningMultiplier(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:top_opening_multiplier][:default].to_f)
        end
        if @hash[:bottom_opening_multiplier]
          openstudio_window_blind.setBlindBottomOpeningMultiplier(@hash[:bottom_opening_multiplier].to_f)
        else
          openstudio_window_blind.setBlindBottomOpeningMultiplier(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:bottom_opening_multiplier][:default].to_f)
        end
        if @hash[:left_opening_multiplier]
          openstudio_window_blind.setBlindLeftSideOpeningMultiplier(@hash[:left_opening_multiplier].to_f)
        else
          openstudio_window_blind.setBlindLeftSideOpeningMultiplier(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:left_opening_multiplier][:default].to_f)
        end
        if @hash[:right_opening_multiplier]
          openstudio_window_blind.setBlindRightSideOpeningMultiplier(@hash[:right_opening_multiplier].to_f)
        else
          openstudio_window_blind.setBlindRightSideOpeningMultiplier(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:right_opening_multiplier][:default].to_f)
        end
        if @hash[:minimum_slat_angle]
          openstudio_window_blind.setMinimumSlatAngle(@hash[:minimum_slat_angle].to_f)
        else
          openstudio_window_blind.setMinimumSlatAngle(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:minimum_slat_angle][:default].to_f)
        end
        if @hash[:maximum_slat_angle]
          openstudio_window_blind.setMaximumSlatAngle(@hash[:maximum_slat_angle].to_f)
        else
          openstudio_window_blind.setMaximumSlatAngle(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:maximum_slat_angle][:default])
        end
        openstudio_window_blind
      end
    end # EnergyWindowMaterialBlind
  end # EnergyModel
end # Ladybug

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

      def initialize(hash)
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'EnergyWindowMaterialBlind'
      end
      
      private
      
      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getBlindByName(@hash[:name]) 
        if object.is_initialized
          return object.get
        end
        return nil
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
        if @hash[:front_beam_solar_reflectance]
          openstudio_window_blind.setFrontSideSlatBeamSolarReflectance(@hash[:front_beam_solar_reflectance].to_f)
        else
          openstudio_window_blind.setFrontSideSlatBeamSolarReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:front_beam_solar_reflectance][:default].to_f)
        end
        if @hash[:back_beam_solar_reflectance]
          openstudio_window_blind.setBackSideSlatBeamSolarReflectance(@hash[:back_beam_solar_reflectance].to_f)
        else
          openstudio_window_blind.setBackSideSlatBeamSolarReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:back_beam_solar_reflectance][:default].to_f)
        end
        if @hash[:diffuse_solar_transmittance]
          openstudio_window_blind.setSlatDiffuseSolarTransmittance(@hash[:diffuse_solar_transmittance].to_f)
        else
          openstudio_window_blind.setSlatDiffuseSolarTransmittance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_solar_transmittance][:default].to_f)
        end
        if @hash[:front_diffuse_solar_reflectance]
          openstudio_window_blind.setFrontSideSlatDiffuseSolarReflectance(@hash[:front_diffuse_solar_reflectance].to_f)
        else
          openstudio_window_blind.setFrontSideSlatDiffuseSolarReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:front_diffuse_solar_reflectance][:default].to_f)
        end
        if @hash[:back_diffuse_solar_reflectance]
          openstudio_window_blind.setBackSideSlatDiffuseSolarReflectance(@hash[:back_diffuse_solar_reflectance].to_f)
        else
          openstudio_window_blind.setBackSideSlatDiffuseSolarReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:back_diffuse_solar_reflectance][:default].to_f)
        end
        if @hash[:diffuse_visible_transmittance]
          openstudio_window_blind.setSlatDiffuseVisibleTransmittance(@hash[:diffuse_visible_transmittance].to_f)
        else
          openstudio_window_blind.setSlatDiffuseVisibleTransmittance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:diffuse_visible_transmittance][:default].to_f)
        end
        if @hash[:front_diffuse_visible_reflectance]
          openstudio_window_blind.setFrontSideSlatDiffuseVisibleReflectance(@hash[:front_diffuse_visible_reflectance].to_f)
        else
          openstudio_window_blind.setFrontSideSlatDiffuseVisibleReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:front_diffuse_visible_reflectance][:default].to_f)
        end
        if @hash[:back_diffuse_visible_reflectance]
          openstudio_window_blind.setBackSideSlatDiffuseVisibleReflectance(@hash[:back_diffuse_visible_reflectance].to_f)
        else
          openstudio_window_blind.setBackSideSlatDiffuseVisibleReflectance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:back_diffuse_visible_reflectance][:default].to_f)
        end
        if @hash[:infrared_hemispherical_transmittance]
          openstudio_window_blind.setSlatInfraredHemisphericalTransmittance(@hash[:infrared_hemispherical_transmittance].to_f)
        else
          openstudio_window_blind.setSlatInfraredHemisphericalTransmittance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:infrared_hemispherical_transmittance][:default].to_f)
        end
        if @hash[:front_infrared_hemispherical_emissivity]
          openstudio_window_blind.setFrontSideSlatInfraredHemisphericalEmissivity(@hash[:front_infrared_hemispherical_emissivity].to_f)
        else
          openstudio_window_blind.setFrontSideSlatInfraredHemisphericalEmissivity(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:front_infrared_hemispherical_emissivity][:default].to_f)
        end
        if @hash[:back_infrared_hemispherical_emissivity]
          openstudio_window_blind.setBackSideSlatInfraredHemisphericalEmissivity(@hash[:back_infrared_hemispherical_emissivity].to_f)
        else
          openstudio_window_blind.setBackSideSlatInfraredHemisphericalEmissivity(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:back_infrared_hemispherical_emissivity][:default].to_f)
        end
        if @hash[:blind_toglass_distance]
          openstudio_window_blind.setBlindtoGlassDistance(@hash[:blind_toglass_distance].to_f)
        else
          openstudio_window_blind.setBlindtoGlassDistance(@@schema[:definitions][:EnergyWindowMaterialBlind][:properties][:blind_toglass_distance][:default].to_f)
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
        return openstudio_window_blind
        puts openstudio_window_blind
      end

    end # EnergyWindowMaterialBlind
  end # EnergyModel
end # Ladybug

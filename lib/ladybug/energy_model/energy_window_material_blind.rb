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
        openstudio_window_blind.setSlatWidth(@hash[:slat_width].to_f)
        openstudio_window_blind.setSlatSeparation(@hash[:slat_separation].to_f)
        openstudio_window_blind.setSlatThickness(@hash[:slat_thickness].to_f)
        openstudio_window_blind.setSlatAngle(@hash[:slat_angle].to_f)
        openstudio_window_blind.setSlatConductivity(@hash[:slat_conductivity].to_f)
        openstudio_window_blind.setSlatBeamSolarTransmittance(@hash[:beam_solar_transmittance].to_f)
        openstudio_window_blind.setFrontSideSlatBeamSolarReflectance(@hash[:front_beam_solar_reflectance].to_f)
        openstudio_window_blind.setBackSideSlatBeamSolarReflectance(@hash[:back_beam_solar_reflectance].to_f)
        openstudio_window_blind.setSlatDiffuseSolarTransmittance(@hash[:diffuse_solar_transmittance].to_f)
        openstudio_window_blind.setFrontSideSlatDiffuseSolarReflectance (@hash[:front_diffuse_solar_reflectance]).to_f
        openstudio_window_blind.setBackSideSlatDiffuseSolarReflectance(@hash[:back_diffuse_solar_reflectance].to_f)
        openstudio_window_blind.setSlatBeamVisibleTransmittance(@hash[:beam_visible_transmittance].to_f)
        openstudio_window_blind.setFrontSideSlatBeamVisibleReflectance (@hash[:front_beam_visible_reflectance].to_f)
        openstudio_window_blind.setBackSideSlatBeamVisibleReflectance(@hash[:back_beam_visible_reflectance].to_f)
        openstudio_window_blind.setSlatDiffuseVisibleTransmittance(@hash[:diffuse_visible_transmittance].to_f)
        openstudio_window_blind.setFrontSideSlatDiffuseVisibleReflectance(@hash[:front_diffuse_visible_reflectance].to_f)
        openstudio_window_blind.setBackSideSlatDiffuseVisibleReflectance(@hash[:back_diffuse_visible_reflectance].to_f)
        openstudio_window_blind.setSlatInfraredHemisphericalTransmittance(@hash[:infrared_hemispherical_transmittance].to_f)
        openstudio_window_blind.setFrontSideSlatInfraredHemisphericalEmissivity(@hash[:front_infrared_hemispherical_emissivity].to_f)
        openstudio_window_blind.setBackSideSlatInfraredHemisphericalEmissivity(@hash[:back_infrared_hemspherical_emissivity].to_f)
        openstudio_window_blind.setBlindtoGlassDistance(@hash[:blind_toglass_distance].to_f)
        openstudio_window_blind.setBlindTopOpeningMultiplier(@hash[:top_opening_multiplier].to_f)
        openstudio_window_blind.setBlindBottomOpeningMultiplier(@hash[:bottom_opening_multiplier].to_f)
        openstudio_window_blind.setBlindLeftSideOpeningMultiplier(@hash[:left_opening_multiplier].to_f)
        openstudio_window_blind.setBlindRightSideOpeningMultiplier(@hash[:right_opening_multiplier].to_f)
        openstudio_window_blind.setMinimumSlatAngle(@hash[:minimum_slat_angle].to_f)
        openstudio_window_blind.setMaximumSlatAngle(@hash[:maximum_slat_angle].to_f)

        return openstudio_window_blind
      end

    end # EnergyWindowMaterialBlind
  end # EnergyModel
end # Ladybug

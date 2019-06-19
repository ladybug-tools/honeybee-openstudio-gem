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
require 'ladybug/energy_model/energy_window_material_gas'
require 'ladybug/energy_model/energy_window_material_gas_custom'
require 'ladybug/energy_model/energy_window_material_gas_mixture'
require 'ladybug/energy_model/energy_window_material_simpleglazsys'
require 'ladybug/energy_model/energy_window_material_blind'
require 'ladybug/energy_model/energy_window_material_glazing'
require 'ladybug/energy_model/energy_window_material_shade'

require 'json-schema'
require 'json'
require 'openstudio'

module Ladybug
  module EnergyModel
    class EnergyConstructionTransparent < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'EnergyConstructionTransparent'
      end

      def defaults
        result = {}
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getConstructionByName(@hash[:name])
        return object.get if object.is_initialized
        nil
      end

      def validation_errors
        result = super

        if (@hash[:materials]).empty?
          result << JSON::Validator.raise("'Transparent construction should at least have one material.'")
        elsif (@hash[:materials]).length > 8
          result << JSON::Validator.raise('Transparent construction cannot have more than 8 materials.')
        end
        result
      end

      def create_openstudio_object(openstudio_model)
        openstudio_construction = OpenStudio::Model::Construction.new(openstudio_model)
        openstudio_construction.setName(@hash[:name])
        openstudio_materials = OpenStudio::Model::MaterialVector.new
        @hash[:materials].each do |material|
          name = material[:name]
          material_type = material[:type]
          material_object = nil

          case material_type
          when 'EnergyWindowMaterialGas'
            material_object = EnergyWindowMaterialGas.new(material)
          when 'EnergyWindowMaterialGasCustom'
            material_object = EnergyWindowMaterialGasCustom.new(material)
          when 'EnergyWindowMaterialGasMixture'
            material_object = EnergyWindowMaterialGasMixture.new(material)
          when 'EnergyWindowMaterialSimpleGlazSys'
            material_object = EnergyWindowMaterialSimpleGlazSys.new(material)
          when 'EnergyWindowMaterialBlind'
            material_object = EnergyWindowMaterialBlind.new(material)
          when 'EnergyWindowMaterialGlazing'
            material_object = EnergyWindowMaterialGlazing.new(material)
          when 'EnergyWindowMaterialShade'
            material_object = EnergyWindowMaterialShade.new(material)
          else
            raise "Unknown material type #{material_type}"
          end

          openstudio_material = material_object.to_openstudio(openstudio_model)
          openstudio_materials << openstudio_material
        end

        openstudio_construction.setLayers(openstudio_materials)
        openstudio_construction
      end
    end # EnergyConstructionTransparent
  end # EnergyModel
end # Ladybug

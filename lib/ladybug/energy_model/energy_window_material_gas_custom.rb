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
    class EnergyWindowMaterialGasCustom < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'EnergyWindowMaterialGasCustom'
      end

      def defaults
        result = {}
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getGasByName(@hash[:name])
        return object.get if object.is_initialized
        nil
      end

      def create_openstudio_object(openstudio_model)
        openstudio_window_gas_custom = OpenStudio::Model::Gas.new(openstudio_model)
        openstudio_window_gas_custom.setName(@hash[:name])
        if @hash[:thickness]
          openstudio_window_gas_custom.setThickness(@hash[:thickness])
        else
          openstudio_window_gas_custom.setThickness(@@schema[:definitions][:EnergyWindowMaterialGasCustom][:properties][:thickness][:default])
        end
        openstudio_window_gas_custom.setGasType('Custom')
        openstudio_window_gas_custom.setConductivityCoefficientA(@hash[:conductivity_coeff_a].to_f)
        if @hash[:conductivity_coeff_b]
          openstudio_window_gas_custom.setConductivityCoefficientB(@hash[:conductivity_coeff_b].to_f)
        else
          openstudio_window_gas_custom.setConductivityCoefficientB(@@schema[:definitions][:EnergyWindowMaterialGasCustom][:properties][:conductivity_coeff_b][:default].to_f)
        end
        if @hash[:conductivity_coeff_c]
          openstudio_window_gas_custom.setConductivityCoefficientC(@hash[:conductivity_coeff_c].to_f)
        else
          openstudio_window_gas_custom.setConductivityCoefficientC(@@schema[:definitions][:EnergyWindowMaterialGasCustom][:properties][:conductivity_coeff_c][:default].to_f)
        end
        openstudio_window_gas_custom.setViscosityCoefficientA(@hash[:viscosity_coeff_a].to_f)
        if @hash[:viscosity_coeff_b]
          openstudio_window_gas_custom.setViscosityCoefficientB(@hash[:viscosity_coeff_b].to_f)
        else
          openstudio_window_gas_custom.setViscosityCoefficientB(@@schema[:definitions][:EnergyWindowMaterialGasCustom][:properties][:viscosity_coeff_b][:default].to_f)
        end
        if @hash[:viscosity_coeff_c]
          openstudio_window_gas_custom.setViscosityCoefficientC(@hash[:viscosity_coeff_c].to_f)
        else
          openstudio_window_gas_custom.setViscosityCoefficientC(@@schema[:definitions][:EnergyWindowMaterialGasCustom][:properties][:viscosity_coeff_c][:default].to_f)
        end
        openstudio_window_gas_custom.setSpecificHeatCoefficientA(@hash[:specific_heat_coeff_a].to_f)
        if @hash[:specific_heat_coeff_b]
          openstudio_window_gas_custom.setSpecificHeatCoefficientB(@hash[:specific_heat_coeff_b].to_f)
        else
          openstudio_window_gas_custom.setSpecificHeatCoefficientB(@@schema[:definitions][:EnergyWindowMaterialGasCustom][:properties][:specific_heat_coeff_b][:default].to_f)
        end
        if @hash[:specific_heat_coeff_c]
          openstudio_window_gas_custom.setSpecificHeatCoefficientC(@hash[:specific_heat_coeff_c].to_f)
        else
          openstudio_window_gas_custom.setConductivityCoefficientC(@@schema[:definitions][:EnergyWindowMaterialGasCustom][:properties][:specific_heat_coeff_c][:default].to_f)
        end
        openstudio_window_gas_custom.setSpecificHeatRatio(@hash[:specific_heat_ratio].to_f)
        openstudio_window_gas_custom.setMolecularWeight(@hash[:molecular_weight].to_f)
        openstudio_window_gas_custom
      end
    end # EnergyWindowMaterialGasCustom
  end # EnergyModel
end # Ladybug

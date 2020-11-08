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

require 'honeybee/material/window_gas_custom'

require 'to_openstudio/model_object'

module Honeybee
  class EnergyWindowMaterialGasCustom

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getGasByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create window gas openstudio object
      os_gas_custom = OpenStudio::Model::Gas.new(openstudio_model)
      os_gas_custom.setName(@hash[:identifier])
      os_gas_custom.setGasType('Custom')
      os_gas_custom.setConductivityCoefficientA(@hash[:conductivity_coeff_a])
      os_gas_custom.setViscosityCoefficientA(@hash[:viscosity_coeff_a])
      os_gas_custom.setSpecificHeatCoefficientA(@hash[:specific_heat_coeff_a])
      os_gas_custom.setSpecificHeatRatio(@hash[:specific_heat_ratio])
      os_gas_custom.setMolecularWeight(@hash[:molecular_weight])

      # assign thickness
      if @hash[:thickness]
        os_gas_custom.setThickness(@hash[:thickness])
      else
        os_gas_custom.setThickness(defaults[:thickness][:default])
      end

      # assign conductivity coefficient b
      if @hash[:conductivity_coeff_b]
        os_gas_custom.setConductivityCoefficientB(@hash[:conductivity_coeff_b])
      else
        os_gas_custom.setConductivityCoefficientB(defaults[:conductivity_coeff_b][:default])
      end

      # assign conductivity coeffient c
      if @hash[:conductivity_coeff_c]
        os_gas_custom.setConductivityCoefficientC(@hash[:conductivity_coeff_c])
      else
        os_gas_custom.setConductivityCoefficientC(defaults[:conductivity_coeff_c][:default])
      end

      # assign viscosity coefficient b
      if @hash[:viscosity_coeff_b]
        os_gas_custom.setViscosityCoefficientB(@hash[:viscosity_coeff_b])
      else
        os_gas_custom.setViscosityCoefficientB(defaults[:viscosity_coeff_b][:default])
      end

      # assign viscosity coefficient c
      if @hash[:viscosity_coeff_c]
        os_gas_custom.setViscosityCoefficientC(@hash[:viscosity_coeff_c])
      else
        os_gas_custom.setViscosityCoefficientC(defaults[:viscosity_coeff_c][:default])
      end

      # assign specific heat coefficient b
      if @hash[:specific_heat_coeff_b]
        os_gas_custom.setSpecificHeatCoefficientB(@hash[:specific_heat_coeff_b])
      else
        os_gas_custom.setSpecificHeatCoefficientB(defaults[:specific_heat_coeff_b][:default])
      end

      # assign specific heat coefficient c
      if @hash[:specific_heat_coeff_c]
        os_gas_custom.setSpecificHeatCoefficientC(@hash[:specific_heat_coeff_c])
      else
        os_gas_custom.setSpecificHeatCoefficientC(defaults[:specific_heat_coeff_c][:default])
      end

      os_gas_custom
    end
  end # EnergyWindowMaterialGasCustom
end # Honeybee

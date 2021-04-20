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

    def self.from_material(material)
        # create an empty hash
        hash = {}
        hash[:type] = 'EnergyWindowMaterialGasCustom'
        # set hash values from OpenStudio Object
        hash[:identifier] = material.nameString
        hash[:thickness] = material.thickness
        # check if boost optional object is empty
        unless material.customConductivityCoefficientA.empty?
            hash[:conductivity_coeff_a] = material.customConductivityCoefficientA.get
        end
        # check if boost optional object is empty
        unless material.customConductivityCoefficientB.empty?
            hash[:conductivity_coeff_b] = material.customConductivityCoefficientB.get
        end
        # check if boost optional object is empty
        unless material.customConductivityCoefficientC.empty?
            hash[:conductivity_coeff_c] = material.customConductivityCoefficientC.get
        end
        # check if boost optional object is empty
        unless material.viscosityCoefficientA.empty?
            hash[:viscosity_coeff_a] = material.viscosityCoefficientA.get
        end
        # check if boost optional object is empty
        unless material.viscosityCoefficientB.empty?
            hash[:viscosity_coeff_b] = material.viscosityCoefficientB.get
        end
        # check if boost optional object is empty
        unless material.viscosityCoefficientC.empty?
            hash[:viscosity_coeff_c] = material.viscosityCoefficientC.get
        end
        # check if boost optional object is empty
        unless material.specificHeatCoefficientA.empty?
            hash[:specific_heat_coeff_a] = material.specificHeatCoefficientA.get
        end
        # check if boost optional object is empty
        unless material.specificHeatCoefficientB.empty?
            hash[:specific_heat_coeff_b] = material.specificHeatCoefficientB.get
        end
        # check if boost optional object is empty
        unless material.specificHeatCoefficientC.empty?
            hash[:specific_heat_coeff_c] = material.specificHeatCoefficientC.get
        end
        # check if boost optional object is empty
        unless material.specificHeatRatio.empty?
            hash[:specific_heat_ratio] = material.specificHeatRatio.get
        end
        # check if boost optional object is empty
        unless material.molecularWeight.empty?
            hash[:molecular_weight] = material.molecularWeight.get
        end

        hash
    end

  end # EnergyWindowMaterialGasCustom
end # Honeybee

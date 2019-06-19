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
    class EnergyWindowMaterialGasMixture < ModelObject
      attr_reader :erros, :warnings

      def initialize(hash = {})
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'EnergyWindowMaterialGasMixture'
      end

      def defaults
        result = {}
        result[:type] = @@schema[:definitions][:EnergyWindowMaterialGasMixture][:properties][:type][:enum]
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getGasMixtureByName(@hash[:name])
        return object.get if object.is_initialized
        nil 
      end

      def create_openstudio_object(openstudio_model)
        openstudio_window_gas_mixture = OpenStudio::Model::GasMixture.new(openstudio_model)
        openstudio_window_gas_mixture.setName(@hash[:name])
        #puts @hash
        openstudio_window_gas_mixture.setThickness(@hash[:thickness])
        openstudio_window_gas_mixture.setGas1Type(@hash[:gas_type_fraction][0][:gas_type])
        openstudio_window_gas_mixture.setGas1Fraction(@hash[:gas_type_fraction][0][:gas_fraction])
        if @hash[:gas_type_fraction][1]
          openstudio_window_gas_mixture.setGas2Type(@hash[:gas_type_fraction][1][:gas_type])
          openstudio_window_gas_mixture.setGas2Fraction(@hash[:gas_type_fraction][1][:gas_fraction])
        else 
          return openstudio_window_gas_mixture
        end
        if @hash[:gas_type_fraction][2]
          openstudio_window_gas_mixture.setGas3Type(@hash[:gas_type_fraction][2][:gas_type])
          openstudio_window_gas_mixture.setGas3Fraction(@hash[:gas_type_fraction][2][:gas_fraction])
        else
          return openstudio_window_gas_mixture
        end
        if @hash[:gas_type_fraction][3]
          openstudio_window_gas_mixture.setGas4Type(@hash[:gas_type_fraction][3][:gas_type])
          openstudio_window_gas_mixture.setGas4Fraction(@hash[:gas_type_fraction][3][:gas_fraction])
        else
          return openstudio_window_gas_mixture
        end
        openstudio_window_gas_mixture
      end

    end #EnergyWindowMaterialGasMixture
  end #EnergyModel
end #Ladybug

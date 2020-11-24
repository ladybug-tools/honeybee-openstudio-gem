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

require 'honeybee/material/window_gas_mixture'

require 'to_openstudio/model_object'

module Honeybee
  class EnergyWindowMaterialGasMixture

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getGasMixtureByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create the gas mixture
      os_gas_mixture = OpenStudio::Model::GasMixture.new(openstudio_model)
      os_gas_mixture.setName(@hash[:identifier])

      # set the thickness
      if @hash[:thickness]
        os_gas_mixture.setThickness(@hash[:thickness])
      else
        os_gas_mixture.setThickness(defaults[:thickness][:default])
      end

      # set the gas types
      @hash[:gas_types].each_index do |i|
        os_gas_mixture.setGasType(i, @hash[:gas_types][i])
      end

      # set the gas fractions
      @hash[:gas_fractions].each_index do |i|
        os_gas_mixture.setGasFraction(i, @hash[:gas_fractions][i])
      end

      os_gas_mixture
    end
  end # EnergyWindowMaterialGasMixture
end # Honeybee

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

require 'from_honeybee/model_object'

require 'openstudio'

module FromHoneybee
  class EnergyMaterialNoMass < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
    end

    def defaults
      @@schema[:components][:schemas][:EnergyMaterialNoMass][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getMasslessOpaqueMaterialByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)

      # create no mass material OpenStudio object and set identifier 
      os_nomass_mat = OpenStudio::Model::MasslessOpaqueMaterial.new(openstudio_model)
      os_nomass_mat.setName(@hash[:identifier])

      # assign thermal resistance
      os_nomass_mat.setThermalResistance(@hash[:r_value])
      
      # assign roughness if it exists
      if @hash[:roughness]
        os_nomass_mat.setRoughness(@hash[:roughness])
      else
        os_nomass_mat.setRoughness(defaults[:roughness][:default])
      end

      # assign thermal absorptance if it exists
      if @hash[:thermal_absorptance]
        os_nomass_mat.setThermalAbsorptance(@hash[:thermal_absorptance])
      else
        os_nomass_mat.setThermalAbsorptance(defaults[:thermal_absorptance][:default])
      end

      # assign solar absorptance if it exists
      if @hash[:solar_absorptance]
        os_nomass_mat.setSolarAbsorptance(@hash[:solar_absorptance])
      else
        os_nomass_mat.setSolarAbsorptance(defaults[:solar_absorptance][:default])
      end

      # assign visible absorptance if it exists
      if @hash[:visible_absorptance]
        os_nomass_mat.setVisibleAbsorptance(@hash[:visible_absorptance])
      else
        os_nomass_mat.setVisibleAbsorptance(defaults[:visible_absorptance][:default])
      end

      os_nomass_mat
    end
  end # EnergyMaterialNoMass
end # FromHoneybee

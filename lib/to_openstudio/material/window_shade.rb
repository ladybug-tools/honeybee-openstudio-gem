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

require 'honeybee/material/window_shade'

require 'to_openstudio/model_object'

module Honeybee
  class EnergyWindowMaterialShade

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getShadeByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create openstudio shade object
      os_shade_mat = OpenStudio::Model::Shade.new(openstudio_model)
      os_shade_mat.setName(@hash[:identifier])

      # assign solar transmittance
      if @hash[:solar_transmittance]
        os_shade_mat.setSolarTransmittance(@hash[:solar_transmittance])
      else
        os_shade_mat.setSolarTransmittance(defaults[:solar_transmittance][:default])
      end

      # assign solar reflectance
      if @hash[:solar_reflectance]
        os_shade_mat.setSolarReflectance(@hash[:solar_reflectance])
      else
        os_shade_mat.setSolarReflectance(defaults[:solar_reflectance][:default])
      end

      # assign visible transmittance
      if @hash[:visible_transmittance]
        os_shade_mat.setVisibleTransmittance(@hash[:visible_transmittance])
      else
        os_shade_mat.setVisibleTransmittance(defaults[:visible_transmittance][:default])
      end

      # assign visible reflectance
      if @hash[:visible_reflectance]
        os_shade_mat.setVisibleReflectance(@hash[:visible_reflectance])
      else
        os_shade_mat.setVisibleReflectance(defaults[:visible_reflectance][:default])
      end

      # assign emissivity
      if @hash[:emissivity]
        os_shade_mat.setThermalHemisphericalEmissivity(@hash[:emissivity])
      else
        os_shade_mat.setThermalHemisphericalEmissivity(defaults[:emissivity][:default])
      end

      # assign infrared transmittance
      if @hash[:infrared_transmittance]
        os_shade_mat.setThermalTransmittance(@hash[:infrared_transmittance])
      else
        os_shade_mat.setThermalTransmittance(defaults[:infrared_transmittance][:default])
      end

      # assign thickness
      if @hash[:thickness]
        os_shade_mat.setThickness(@hash[:thickness])
      else
        os_shade_mat.setThickness(defaults[:thickness][:default])
      end

      # assign conductivity
      if @hash[:conductivity]
        os_shade_mat.setConductivity(@hash[:conductivity])
      else
        os_shade_mat.setConductivity(defaults[:conductivity][:default])
      end

      # assign distance to glass
      if @hash[:distance_to_glass]
        os_shade_mat.setShadetoGlassDistance(@hash[:distance_to_glass])
      else
        os_shade_mat.setShadetoGlassDistance(defaults[:distance_to_glass][:default])
      end

      # assign top opening multiplier
      if @hash[:top_opening_multiplier]
        os_shade_mat.setTopOpeningMultiplier(@hash[:top_opening_multiplier])
      else
        os_shade_mat.setTopOpeningMultiplier(defaults[:top_opening_multiplier][:default])
      end

      # assign bottom opening multiplier
      if @hash[:bottom_opening_multiplier]
        os_shade_mat.setBottomOpeningMultiplier(@hash[:bottom_opening_multiplier])
      else
        os_shade_mat.setBottomOpeningMultiplier(defaults[:bottom_opening_multiplier][:default])
      end

      # assign left opening multiplier
      if @hash[:left_opening_multiplier]
        os_shade_mat.setLeftSideOpeningMultiplier(@hash[:left_opening_multiplier])
      else
        os_shade_mat.setLeftSideOpeningMultiplier(defaults[:left_opening_multiplier][:default])
      end

      # assign right opening muliplier
      if @hash[:right_opening_multiplier]
        os_shade_mat.setRightSideOpeningMultiplier(@hash[:right_opening_multiplier])
      else
        os_shade_mat.setRightSideOpeningMultiplier(defaults[:right_opening_multiplier][:default])
      end

      # assign airflow permeability
      if @hash[:airflow_permeability]
        os_shade_mat.setAirflowPermeability(@hash[:airflow_permeability])
      else
        os_shade_mat.setAirflowPermeability(defaults[:airflow_permeability][:default])
      end

      os_shade_mat
    end
  end # EnergyWindowMaterialShade
end # Honeybee

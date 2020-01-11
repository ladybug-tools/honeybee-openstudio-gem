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

require 'openstudio'

module Ladybug
  module EnergyModel
    class EnergyWindowMaterialShade < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash)
        super(hash)
      end

      def defaults
        result = {}
        result[:type] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:type][:enum]
        result[:solar_transmittance] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:solar_transmittance][:default]
        result[:solar_reflectance] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:solar_reflectance][:default]
        result[:visible_transmittance] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:visible_transmittance][:default]
        result[:visible_reflectance] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:visible_reflectance][:default]
        result[:emissivity] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:emissivity][:default]
        result[:infrared_transmittance] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:infrared_transmittance][:default]
        result[:thickness] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:thickness][:default]
        result[:conductivity] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:conductivity][:default]
        result[:distance_to_glass] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:distance_to_glass][:default]
        result[:top_opening_multiplier] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:top_opening_multiplier][:default]
        result[:bottom_opening_multiplier] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:bottom_opening_multiplier][:default].to_f
        result[:left_opening_multiplier] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:left_opening_multiplier][:default]
        result[:right_opening_multiplier] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:right_opening_multiplier][:default]
        result[:airflow_permeability] = @@schema[:components][:schemas][:EnergyWindowMaterialShade][:properties][:airflow_permeability][:default]
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getShadeByName(@hash[:name])
        return object.get if object.is_initialized
        nil
      end

      def create_openstudio_object(openstudio_model)
        openstudio_material_shade = OpenStudio::Model::Shade.new(openstudio_model)
        openstudio_material_shade.setName(@hash[:name])
        if @hash[:solar_transmittance]
          openstudio_material_shade.setSolarTransmittance(@hash[:solar_transmittance])
        else
          openstudio_material_shade.setSolarTransmittance(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:solar_transmittance][:default])
        end
        if @hash[:solar_reflectance]
          openstudio_material_shade.setSolarReflectance(@hash[:solar_reflectance])
        else
          openstudio_material_shade.setSolarReflectance(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:solar_reflectance][:default])
        end
        if @hash[:visible_transmittance]
          openstudio_material_shade.setVisibleTransmittance(@hash[:visible_transmittance])
        else
          openstudio_material_shade.setVisibleTransmittance(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:visible_transmittance][:default])
        end
        if @hash[:visible_reflectance]
          openstudio_material_shade.setVisibleReflectance(@hash[:visible_reflectance])
        else
          openstudio_material_shade.setVisibleReflectance(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:visible_reflectance][:default])
        end
        if @hash[:emissivity]
          openstudio_material_shade.setThermalHemisphericalEmissivity(@hash[:emissivity])
        else
          openstudio_material_shade.setThermalHemisphericalEmissivity(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:emissivity][:default])
        end
        if @hash[:infrared_transmittance]
          openstudio_material_shade.setThermalTransmittance(@hash[:infrared_transmittance])
        else
          openstudio_material_shade.setThermalTransmittance(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:infrared_transmittance][:default])
        end
        if @hash[:thickness]
          openstudio_material_shade.setThickness(@hash[:thickness])
        else
          openstudio_material_shade.setThickness(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:thickness][:default])
        end
        if @hash[:conductivity]
          openstudio_material_shade.setConductivity(@hash[:conductivity])
        else
          openstudio_material_shade.setConductivity(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:conductivity][:default])
        end
        if @hash[:distance_to_glass]
          openstudio_material_shade.setShadetoGlassDistance(@hash[:distance_to_glass])
        else
          openstudio_material_shade.setShadetoGlassDistance(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:shade_toglass_distance][:default])
        end
        if @hash[:top_opening_multiplier]
          openstudio_material_shade.setTopOpeningMultiplier(@hash[:top_opening_multiplier])
        else
          openstudio_material_shade.setTopOpeningMultiplier(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:top_opening_multiplier][:default])
        end
        if @hash[:bottom_opening_multiplier]
          openstudio_material_shade.setBottomOpeningMultiplier(@hash[:bottom_opening_multiplier].to_f)
        else
          openstudio_material_shade.setSolarReflectance(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:bottom_opening_multiplier][:default].to_f)
        end
        if @hash[:left_opening_multiplier]
          openstudio_material_shade.setLeftSideOpeningMultiplier(@hash[:left_opening_multiplier])
        else
          openstudio_material_shade.setLeftSideOpeningMultiplier(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:left_opening_multiplier][:default])
        end
        if @hash[:right_opening_multiplier]
          openstudio_material_shade.setRightSideOpeningMultiplier(@hash[:right_opening_multiplier])
        else
          openstudio_material_shade.setRightSideOpeningMultiplier(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:right_opening_multiplier][:default])
        end
        if @hash[:airflow_permeability]
          openstudio_material_shade.setAirflowPermeability(@hash[:airflow_permeability])
        else
          openstudio_material_shade.setAirflowPermeability(@@schema[:components][:schemas][EnergyWindowMaterialGlazing][:properties][:airflow_permeability][:default])
        end
        openstudio_material_shade
      end
    end # EnergyWindowMaterialShade
  end # EnergyModel
end # Ladybug

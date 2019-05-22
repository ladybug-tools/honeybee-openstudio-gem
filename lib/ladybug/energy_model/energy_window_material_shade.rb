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
    class EnergyWindowMaterialShade < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash)
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'EnergyWindowMaterialShade'
      end
      
      private
      
      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getShadeByName(@hash[:name]) 
        if object.is_initialized
          return object.get
        end
        return nil
      end
      
      def create_openstudio_object(openstudio_model)
        openstudio_material_shade = OpenStudio::Model::Shade.new(openstudio_model)
        openstudio_material_shade.setName(@hash[:name])
        if @hash[:solar_transmittance]
          openstudio_material_shade.setSolarTransmittance(@hash[:solar_transmittance])
        else 
          openstudio_material_shade.setSolarTransmittance(@schema[EnergyWindowMaterialGlazing][:solar_transmittance][:default])
        end
        if @hash[:solar_reflectance]
          openstudio_material_shade.setSolarReflectance(@hash[:solar_reflectance])
        else 
          openstudio_material_shade.setSolarReflectance(@schema[EnergyWindowMaterialGlazing][:solar_reflectance][:default])
        end
        if @hash[:visible_transmittance]
          openstudio_material_shade.setVisibleTransmittance(@hash[:visible_transmittance])
        else 
          openstudio_material_shade.setVisibleTransmittance(@schema[EnergyWindowMaterialGlazing][:visible_transmittance][:default])
        end
        if @hash[:visible_reflectance]
          openstudio_material_shade.setVisibleReflectance(@hash[:visible_reflectance])
        else 
          openstudio_material_shade.setVisibleReflectance(@schema[EnergyWindowMaterialGlazing][:visible_reflectance][:default])
        end
        if @hash[:infrared_hemispherical_emissivity]
          openstudio_material_shade.setThermalHemisphericalEmissivity(@hash[:infrared_hemispherical_emissivity])
        else 
          openstudio_material_shade.setThermalHemisphericalEmissivity(@schema[EnergyWindowMaterialGlazing][:infrared_hemispherical_emissivity][:default])
        end
        if @hash[:infrared_transmittance]
          openstudio_material_shade.setThermalTransmittance(@hash[:infrared_transmittance])
        else 
          openstudio_material_shade.setThermalTransmittance(@schema[EnergyWindowMaterialGlazing][:infrared_transmittance][:default])
        end
        if @hash[:thickness]
          openstudio_material_shade.setThickness(@hash[:thickness])
        else 
          openstudio_material_shade.setThickness(@schema[EnergyWindowMaterialGlazing][:thickness][:default])
        end
        if @hash[:conductivity]
          openstudio_material_shade.setConductivity(@hash[:conductivity])
        else 
          openstudio_material_shade.setConductivity(@schema[EnergyWindowMaterialGlazing][:conductivity][:default])
        end
        if @hash[:shade_toglass_distance]
          openstudio_material_shade.setShadetoGlassDistance(@hash[:shade_toglass_distance])
        else 
          openstudio_material_shade.setShadetoGlassDistance(@schema[EnergyWindowMaterialGlazing][:shade_toglass_distance][:default])
        end
        if @hash[:top_opening_multiplier]
          openstudio_material_shade.setTopOpeningMultiplier(@hash[:top_opening_multiplier])
        else 
          openstudio_material_shade.setTopOpeningMultiplier(@schema[EnergyWindowMaterialGlazing][:top_opening_multiplier][:default])
        end
        if @hash[:bottom_opening_multiplier]
          openstudio_material_shade.setBottomOpeningMultiplier(@hash[:bottom_opening_multiplier].to_f)
        else 
          openstudio_material_shade.setSolarReflectance(@schema[EnergyWindowMaterialGlazing][:solar_reflectance][:default].to_f)
        end
        if @hash[:left_opening_multiplier]
          openstudio_material_shade.setLeftSideOpeningMultiplier(@hash[:left_opening_multiplier])
        else 
          openstudio_material_shade.setLeftSideOpeningMultiplier(@schema[EnergyWindowMaterialGlazing][:left_opening_multiplier][:default])
        end
        if @hash[:right_opening_multiplier]
          openstudio_material_shade.setRightSideOpeningMultiplier(@hash[:right_opening_multiplier])
        else 
          openstudio_material_shade.setRightSideOpeningMultiplier(@schema[EnergyWindowMaterialGlazing][:right_opening_multiplier][:default])
        end
        if @hash[:airflow_permeability]
          openstudio_material_shade.setAirflowPermeability(@hash[:airflow_permeability])
        else 
          openstudio_material_shade.setAirflowPermeability(@schema[EnergyWindowMaterialGlazing][:airflow_permeability][:default])
        end
        return openstudio_material_shade
      end

    end # EnergyWindowMaterialShade
  end # EnergyModel
end # Ladybug

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

require 'honeybee/material/vegetation'

require 'to_openstudio/model_object'

module Honeybee
  class EnergyMaterialVegetation < ModelObject

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getRoofVegetationByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create standard opaque OpenStudio material
      os_veg_mat = OpenStudio::Model::RoofVegetation.new(openstudio_model)
      os_veg_mat.setName(@hash[:identifier])
      unless @hash[:display_name].nil?
        os_veg_mat.setDisplayName(@hash[:display_name])
      end
      os_veg_mat.setSoilLayerName(@hash[:identifier] + '{}_SoilLayer')

      # assign thickness if it exists
      if @hash[:thickness]
        os_veg_mat.setThickness(@hash[:thickness])
      else
        os_veg_mat.setThickness(defaults[:thickness][:default])
      end

      # assign conductivity if it exists
      if @hash[:conductivity]
        os_veg_mat.setConductivityofDrySoil(@hash[:conductivity])
      else
        os_veg_mat.setConductivityofDrySoil(defaults[:conductivity][:default])
      end

      # assign density if it exists
      if @hash[:density]
        os_veg_mat.setDensityofDrySoil(@hash[:density])
      else
        os_veg_mat.setDensityofDrySoil(defaults[:density][:default])
      end

      # assign specific_heat if it exists
      if @hash[:specific_heat]
        os_veg_mat.setSpecificHeatofDrySoil(@hash[:specific_heat])
      else
        os_veg_mat.setSpecificHeatofDrySoil(defaults[:specific_heat][:default])
      end

      # assign roughness if it exists
      if @hash[:roughness]
        os_veg_mat.setRoughness(@hash[:roughness])
      else
        os_veg_mat.setRoughness(defaults[:roughness][:default])
      end

      # assign thermal absorptance if it exists
      if @hash[:soil_thermal_absorptance]
        os_veg_mat.setThermalAbsorptance(@hash[:soil_thermal_absorptance])
      else
        os_veg_mat.setThermalAbsorptance(defaults[:soil_thermal_absorptance][:default])
      end

      # assign solar absorptance if it exists
      if @hash[:soil_solar_absorptance]
        os_veg_mat.setSolarAbsorptance(@hash[:soil_solar_absorptance])
      else
        os_veg_mat.setSolarAbsorptance(defaults[:soil_solar_absorptance][:default])
      end

      # assign visible absorptance if it exists
      if @hash[:soil_visible_absorptance]
        os_veg_mat.setVisibleAbsorptance(@hash[:soil_visible_absorptance])
      else
        os_veg_mat.setVisibleAbsorptance(defaults[:soil_visible_absorptance][:default])
      end

      # assign plant_height if it exists
      if @hash[:plant_height]
        os_veg_mat.setHeightofPlants(@hash[:plant_height])
      else
        os_veg_mat.setHeightofPlants(defaults[:plant_height][:default])
      end

      # assign leaf_area_index if it exists
      if @hash[:leaf_area_index]
        os_veg_mat.setLeafAreaIndex(@hash[:leaf_area_index])
      else
        os_veg_mat.setLeafAreaIndex(defaults[:leaf_area_index][:default])
      end

      # assign leaf_reflectivity if it exists
      if @hash[:leaf_reflectivity]
        os_veg_mat.setLeafReflectivity(@hash[:leaf_reflectivity])
      else
        os_veg_mat.setLeafReflectivity(defaults[:leaf_reflectivity][:default])
      end

      # assign leaf_emissivity if it exists
      if @hash[:leaf_emissivity]
        os_veg_mat.setLeafEmissivity(@hash[:leaf_emissivity])
      else
        os_veg_mat.setLeafEmissivity(defaults[:leaf_emissivity][:default])
      end

      # assign min_stomatal_resist if it exists
      if @hash[:min_stomatal_resist]
        os_veg_mat.setMinimumStomatalResistance(@hash[:min_stomatal_resist])
      else
        os_veg_mat.setMinimumStomatalResistance(defaults[:min_stomatal_resist][:default])
      end

      # assign sat_vol_moist_cont if it exists
      if @hash[:sat_vol_moist_cont]
        os_veg_mat.setSaturationVolumetricMoistureContentoftheSoilLayer(@hash[:sat_vol_moist_cont])
      else
        os_veg_mat.setSaturationVolumetricMoistureContentoftheSoilLayer(defaults[:sat_vol_moist_cont][:default])
      end

      # assign residual_vol_moist_cont if it exists
      if @hash[:residual_vol_moist_cont]
        os_veg_mat.setResidualVolumetricMoistureContentoftheSoilLayer(@hash[:residual_vol_moist_cont])
      else
        os_veg_mat.setResidualVolumetricMoistureContentoftheSoilLayer(defaults[:residual_vol_moist_cont][:default])
      end

      # assign init_vol_moist_cont if it exists
      if @hash[:init_vol_moist_cont]
        os_veg_mat.setInitialVolumetricMoistureContentoftheSoilLayer(@hash[:init_vol_moist_cont])
      else
        os_veg_mat.setInitialVolumetricMoistureContentoftheSoilLayer(defaults[:init_vol_moist_cont][:default])
      end

      # assign moist_diff_model if it exists
      if @hash[:moist_diff_model]
        os_veg_mat.setMoistureDiffusionCalculationMethod(@hash[:moist_diff_model])
      else
        os_veg_mat.setMoistureDiffusionCalculationMethod(defaults[:moist_diff_model][:default])
      end

      os_veg_mat
    end
  end # EnergyMaterialVegetation
end # Honeybee

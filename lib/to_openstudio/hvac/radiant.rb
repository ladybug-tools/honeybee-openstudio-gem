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

# Note: This file is derived from the "Radiant Slab with DOAS" measure
# https://github.com/NREL/openstudio-model-articulation-gem/tree/develop/lib/measures/radiant_slab_with_doas
# It is intended that this file be updated if changes are made to the original measure

class OpenStudio::Model::Model
  # Adds a radiant HVAC system to the model
  def add_radiant_hvac_system(std, system_type, zones, rad_props)
    # the 'zones' argument includes zones that have heating, cooling, or both
    conditioned_zones = zones.select { |zone| std.thermal_zone_heated?(zone) && std.thermal_zone_cooled?(zone) }

    # get the climate zone from the model, which will help set water temerpatures
    climate_zone_obj = self.getClimateZones.getClimateZone('ASHRAE', 2006)
    if climate_zone_obj.empty
      climate_zone_obj = self.getClimateZones.getClimateZone('ASHRAE', 2013)
    end
    if climate_zone_obj.empty || climate_zone_obj.value == ''
        climate_zone = ''
      else
        climate_zone = climate_zone_obj.value
      end
    
    # get the radiant hot water temperature based on the climate zone
    case climate_zone
    when '0', '1'
      radiant_htg_dsgn_sup_wtr_temp_f = 90.0
    when '2', '2A', '2B'
      radiant_htg_dsgn_sup_wtr_temp_f = 100.0
    when '3', '3A', '3B', '3C'
      radiant_htg_dsgn_sup_wtr_temp_f = 100.0
    when '4', '4A', '4B', '4C'
      radiant_htg_dsgn_sup_wtr_temp_f = 100.0
    when '5', '5A', '5B', '5C'
      radiant_htg_dsgn_sup_wtr_temp_f = 110.0
    when '6', '6A', '6B'
      radiant_htg_dsgn_sup_wtr_temp_f = 120.0
    when '7', '8'
      radiant_htg_dsgn_sup_wtr_temp_f = 120.0
    else  # unrecognized climate zone; default to climate zone 4
      radiant_htg_dsgn_sup_wtr_temp_f = 100.0
    end

    # create the hot water loop
    if system_type.include? 'ASHP'
      boiler_fuel_type = 'ASHP'
    elsif system_type.include? 'Boiler'
      boiler_fuel_type = 'NaturalGas'
    elsif system_type.include? 'DHW'
      boiler_fuel_type = 'DistrictHeating'
    end
    hot_water_loop = std.model_add_hw_loop(
      self,
      boiler_fuel_type,
      dsgn_sup_wtr_temp: radiant_htg_dsgn_sup_wtr_temp_f,
      dsgn_sup_wtr_temp_delt: 10.0)

    # create the chilled water loop
    if system_type.include? 'Radiant_Chiller'  # water-cooled chiller
      # make condenser water loop
      fan_type = std.model_cw_loop_cooling_tower_fan_type(self)
      condenser_water_loop = std.model_add_cw_loop(
        self,
        cooling_tower_type: 'Open Cooling Tower',
        cooling_tower_fan_type: 'Propeller or Axial',
        cooling_tower_capacity_control: fan_type,
        number_of_cells_per_tower: 1,
        number_cooling_towers: 1)
      # make chilled water loop
      chilled_water_loop = std.model_add_chw_loop(
        self,
        chw_pumping_type: 'const_pri_var_sec',
        dsgn_sup_wtr_temp: 55.0,
        dsgn_sup_wtr_temp_delt: 5.0,
        chiller_cooling_type: 'WaterCooled',
        condenser_water_loop: condenser_water_loop)
    elsif system_type.include? 'Radiant_ACChiller'  # air-cooled chiller
      chilled_water_loop = std.model_add_chw_loop(
        self,
        chw_pumping_type: 'const_pri_var_sec',
        dsgn_sup_wtr_temp: 55.0,
        dsgn_sup_wtr_temp_delt: 5.0,
        chiller_cooling_type: 'AirCooled')
    else  # district chilled water cooled
        chilled_water_loop = std.model_add_chw_loop(
          self,
          cooling_fuel: 'DistrictCooling',
          chw_pumping_type: 'const_pri_var_sec',
          dsgn_sup_wtr_temp: 55.0,
          dsgn_sup_wtr_temp_delt: 5.0)
    end

    # get the various controls for the radiant system
    if rad_props[:proportional_gain]
      proportional_gain = rad_props[:proportional_gain]
    else
      proportional_gain = 0.3
    end
    if rad_props[:minimum_operation_time]
      minimum_operation = rad_props[:minimum_operation_time]
    else
      minimum_operation = 1
    end
    if rad_props[:switch_over_time]
      switch_over_time = rad_props[:switch_over_time]
    else
      switch_over_time = 24
    end

    # add radiant system to the conditioned zones
    include_carpet = false
    if rad_props[:radiant_face_type]
      radiant_type = rad_props[:radiant_face_type].downcase
      if radiant_type == 'floorwithcarpet'
        radiant_type = 'floor'
        include_carpet = true
      end
    else
      radiant_type = 'floor'
    end
    radiant_loops = std.model_add_low_temp_radiant(
      self, conditioned_zones, hot_water_loop, chilled_water_loop,
      radiant_type: radiant_type,
      include_carpet: include_carpet,
      proportional_gain: proportional_gain,
      minimum_operation: minimum_operation,
      switch_over_time: switch_over_time)

    # if the equipment includes a DOAS, then add it
    if system_type.include? 'DOAS_'
      std.model_add_doas(self, conditioned_zones)
    end

  end
end
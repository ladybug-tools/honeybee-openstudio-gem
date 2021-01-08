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

# Note: This file is copied directly from the "Create Typical DOE Building from Model" measure
# https://bcl.nrel.gov/node/85019
# It is intended that this file be re-copied if new system types are added

class OpenStudio::Model::Model
  # Adds the HVAC system as derived from the combinations of CBECS 2012 MAINHT and MAINCL fields.
  # Mapping between combinations and HVAC systems per http://www.nrel.gov/docs/fy08osti/41956.pdf
  # Table C-31
  def add_cbecs_hvac_system(standard, system_type, zones)
    # the 'zones' argument includes zones that have heating, cooling, or both
    # if the HVAC system type serves a single zone, handle zones with only heating separately by adding unit heaters
    # applies to system types PTAC, PTHP, PSZ-AC, and Window AC
    heated_and_cooled_zones = zones.select { |zone| standard.thermal_zone_heated?(zone) && standard.thermal_zone_cooled?(zone) }
    heated_zones = zones.select { |zone| standard.thermal_zone_heated?(zone) }
    cooled_zones = zones.select { |zone| standard.thermal_zone_cooled?(zone) }
    cooled_only_zones = zones.select { |zone| !standard.thermal_zone_heated?(zone) && standard.thermal_zone_cooled?(zone) }
    heated_only_zones = zones.select { |zone| standard.thermal_zone_heated?(zone) && !standard.thermal_zone_cooled?(zone) }
    system_zones = heated_and_cooled_zones + cooled_only_zones

    # system type naming convention:
    # [ventilation strategy] [ cooling system and plant] [heating system and plant]

    case system_type

    when 'ElectricBaseboard'
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'BoilerBaseboard'
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'ASHPBaseboard'
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'AirSourceHeatPump', znht = nil, cl = nil, heated_zones)

    when 'DHWBaseboard'
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'DistrictHeating', znht = nil, cl = nil, heated_zones)

    when 'EvapCoolers_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)
      standard.model_add_hvac_system(self, 'Evaporative Cooler', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)

    when 'EvapCoolers_BoilerBaseboard'
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)
      standard.model_add_hvac_system(self, 'Evaporative Cooler', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)

    when 'EvapCoolers_ASHPBaseboard'
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'AirSourceHeatPump', znht = nil, cl = nil, heated_zones)
      standard.model_add_hvac_system(self, 'Evaporative Cooler', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)

    when 'EvapCoolers_DHWBaseboard'
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'DistrictHeating', znht = nil, cl = nil, heated_zones)
      standard.model_add_hvac_system(self, 'Evaporative Cooler', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)

    when 'EvapCoolers_Furnace'
      # Using unit heater to represent forced air furnace to limit to one airloop per thermal zone.
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)
      standard.model_add_hvac_system(self, 'Evaporative Cooler', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)

    when 'EvapCoolers_UnitHeaters'
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)
      standard.model_add_hvac_system(self, 'Evaporative Cooler', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)

    when 'EvapCoolers'
      standard.model_add_hvac_system(self, 'Evaporative Cooler', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)

    when 'DOAS_FCU_Chiller_Boiler'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones,
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_Chiller_ASHP'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'AirSourceHeatPump', znht = nil, cl = 'Electricity', zones)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'AirSourceHeatPump', znht = nil, cl = 'Electricity', zones,
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_Chiller_DHW'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'DistrictHeating', znht = nil, cl = 'Electricity', zones)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'DistrictHeating', znht = nil, cl = 'Electricity', zones,
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_Chiller_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'DOAS', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     air_loop_heating_type: nil)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     zone_equipment_ventilation: false)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'DOAS_FCU_Chiller_GasHeaters'
      standard.model_add_hvac_system(self, 'DOAS', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     air_loop_heating_type: nil)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     zone_equipment_ventilation: false)
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'DOAS_FCU_Chiller'
      standard.model_add_hvac_system(self, 'DOAS', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     air_loop_heating_type: nil)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_ACChiller_Boiler'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled',
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_ACChiller_ASHP'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'AirSourceHeatPump', znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'AirSourceHeatPump', znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled',
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_ACChiller_DHW'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'DistrictHeating', znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'DistrictHeating', znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled',
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_ACChiller_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'DOAS', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled', air_loop_heating_type: nil)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled',
                                     zone_equipment_ventilation: false)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'DOAS_FCU_ACChiller_GasHeaters'
      standard.model_add_hvac_system(self, 'DOAS', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled', air_loop_heating_type: nil)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled',
                                     zone_equipment_ventilation: false)
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'DOAS_FCU_ACChiller'
      standard.model_add_hvac_system(self, 'DOAS', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled', air_loop_heating_type: nil)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled',
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_DCW_Boiler'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'NaturalGas', znht = nil, cl = 'DistrictCooling', zones)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'NaturalGas', znht = nil, cl = 'DistrictCooling', zones,
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_DCW_ASHP'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'AirSourceHeatPump', znht = nil, cl = 'DistrictCooling', zones)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'AirSourceHeatPump', znht = nil, cl = 'DistrictCooling', zones,
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_DCW_DHW'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'DistrictHeating', znht = nil, cl = 'DistrictCooling', zones)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'DistrictHeating', znht = nil, cl = 'DistrictCooling', zones,
                                     zone_equipment_ventilation: false)

    when 'DOAS_FCU_DCW_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'DOAS', ht = nil, znht = nil, cl = 'DistrictCooling', zones,
                                     air_loop_heating_type: nil)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'DistrictCooling', zones,
                                     zone_equipment_ventilation: false)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'DOAS_FCU_DCW_GasHeaters'
      standard.model_add_hvac_system(self, 'DOAS', ht = nil, znht = nil, cl = 'DistrictCooling', zones,
                                     air_loop_heating_type: nil)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'DistrictCooling', zones,
                                     zone_equipment_ventilation: false)
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'DOAS_FCU_DCW'
      standard.model_add_hvac_system(self, 'DOAS', ht = nil, znht = nil, cl = 'DistrictCooling', zones,
                                     air_loop_heating_type: nil)
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'DistrictCooling', zones,
                                     zone_equipment_ventilation: false)

    when 'DOAS_VRF'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'Electricity', znht = nil, cl = 'Electricity', zones,
                                     air_loop_heating_type: 'DX',
                                     air_loop_cooling_type: 'DX')
      standard.model_add_hvac_system(self, 'VRF', ht = 'Electricity', znht = nil, cl = 'Electricity', zones)

    when 'DOAS_WSHP_FluidCooler_Boiler'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones)
      standard.model_add_hvac_system(self, 'Water Source Heat Pumps', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones,
                                     heat_pump_loop_cooling_type: 'FluidCooler',
                                     zone_equipment_ventilation: false)

    when 'DOAS_WSHP_CoolingTower_Boiler'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones)
      standard.model_add_hvac_system(self, 'Water Source Heat Pumps', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones,
                                     heat_pump_loop_cooling_type: 'CoolingTower',
                                     zone_equipment_ventilation: false)

    when 'DOAS_WSHP_GSHP'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'Electricity', znht = nil, cl = 'Electricity', zones,
                                     air_loop_heating_type: 'DX',
                                     air_loop_cooling_type: 'DX')
      standard.model_add_hvac_system(self, 'Ground Source Heat Pumps', ht = 'Electricity', znht = nil, cl = 'Electricity', zones,
                                     zone_equipment_ventilation: false)

    when 'DOAS_WSHP_DCW_DHW'
      standard.model_add_hvac_system(self, 'DOAS', ht = 'DistrictHeating', znht = nil, cl = 'DistrictCooling', zones)
      standard.model_add_hvac_system(self, 'Water Source Heat Pumps', ht = 'DistrictHeating', znht = nil, cl = 'DistrictCooling', zones,
                                     zone_equipment_ventilation: false)

    # ventilation provided by zone fan coil unit in fan coil systems
    when 'FCU_Chiller_Boiler'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones)

    when 'FCU_Chiller_ASHP'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'AirSourceHeatPump', znht = nil, cl = 'Electricity', zones)

    when 'FCU_Chiller_DHW'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'DistrictHeating', znht = nil, cl = 'Electricity', zones)

    when 'FCU_Chiller_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'FCU_Chiller_GasHeaters'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones)
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'FCU_Chiller'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones)

    when 'FCU_ACChiller_Boiler'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')

    when 'FCU_ACChiller_ASHP'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'AirSourceHeatPump', znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')

    when 'FCU_ACChiller_DHW'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'DistrictHeating', znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')

    when 'FCU_ACChiller_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'FCU_ACChiller_GasHeaters'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'FCU_ACChiller'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')

    when 'FCU_DCW_Boiler'
      standard.model_add_hvac_system(self, 'Fan Coil ', ht = 'NaturalGas', znht = nil, cl = 'DistrictCooling', zones)

    when 'FCU_DCW_ASHP'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'AirSourceHeatPump', znht = nil, cl = 'DistrictCooling', zones)

    when 'FCU_DCW_DHW'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = 'DistrictHeating', znht = nil, cl = 'DistrictCooling', zones)

    when 'FCU_DCW_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'DistrictCooling', zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'FCU_DCW_GasHeaters'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'DistrictCooling', zones)
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'FCU_DCW'
      standard.model_add_hvac_system(self, 'Fan Coil', ht = nil, znht = nil, cl = 'DistrictCooling', zones)

    when 'Furnace'
      # includes ventilation, whereas residential forced air furnace does not.
      standard.model_add_hvac_system(self, 'Forced Air Furnace', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'GasHeaters'
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'PTAC_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'PTAC', ht = nil, znht = nil, cl = 'Electricity', system_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'PTAC_BoilerBaseboard'
      standard.model_add_hvac_system(self, 'PTAC', ht = nil, znht = nil, cl = 'Electricity', system_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'PTAC_DHWBaseboard'
      standard.model_add_hvac_system(self, 'PTAC', ht = nil, znht = nil, cl = 'Electricity', system_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'DistrictHeating', znht = nil, cl = nil, heated_zones)

    when 'PTAC_GasHeaters'
      standard.model_add_hvac_system(self, 'PTAC', ht = nil, znht = nil, cl = 'Electricity', system_zones)
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'PTAC_ElectricCoil'
      standard.model_add_hvac_system(self, 'PTAC', ht = nil, znht = 'Electricity', cl = 'Electricity', system_zones)
      # use 'Baseboard electric' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_only_zones)

    when 'PTAC_GasCoil'
      standard.model_add_hvac_system(self, 'PTAC', ht = nil, znht = 'NaturalGas', cl = 'Electricity', system_zones)
      # use 'Baseboard electric' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_only_zones)

    when 'PTAC_Boiler'
      standard.model_add_hvac_system(self, 'PTAC', ht = 'NaturalGas', znht = nil, cl = 'Electricity', system_zones)
      # use 'Baseboard gas boiler' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_only_zones)

    when 'PTAC_ASHP'
      standard.model_add_hvac_system(self, 'PTAC', ht = 'AirSourceHeatPump', znht = nil, cl = 'Electricity', system_zones)
      # use 'Baseboard central air source heat pump' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'AirSourceHeatPump', znht = nil, cl = nil, heated_only_zones)

    when 'PTAC_DHW'
      standard.model_add_hvac_system(self, 'PTAC', ht = 'DistrictHeating', znht = nil, cl = 'Electricity', system_zones)
      # use 'Baseboard district hot water heat' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'DistrictHeating', znht = nil, cl = nil, heated_only_zones)

    when 'PTAC'
      standard.model_add_hvac_system(self, 'PTAC', ht = nil, znht = nil, cl = 'Electricity', system_zones)

    when 'PTHP'
      standard.model_add_hvac_system(self, 'PTHP', ht = 'Electricity', znht = nil, cl = 'Electricity', system_zones)
      # use 'Baseboard electric' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = nil, cl = 'Electricity', system_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'PSZAC_BoilerBaseboard'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = nil, cl = 'Electricity', system_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'PSZAC_DHWBaseboard'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = nil, cl = 'Electricity', system_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'DistrictHeating', znht = nil, cl = nil, heated_zones)

    when 'PSZAC_GasHeaters'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = nil, cl = 'Electricity', system_zones)
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'PSZAC_ElectricCoil'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = 'Electricity', cl = 'Electricity', system_zones)
      # use 'Baseboard electric' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_GasCoil'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = 'NaturalGas', cl = 'Electricity', system_zones)
      # use 'Baseboard electric' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_Boiler'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = 'NaturalGas', znht = nil, cl = 'Electricity', system_zones)
      # use 'Baseboard gas boiler' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_ASHP'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = 'AirSourceHeatPump', znht = nil, cl = 'Electricity', system_zones)
      # use 'Baseboard central air source heat pump' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'AirSourceHeatPump', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_DHW'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = 'DistrictHeating', znht = nil, cl = 'Electricity', system_zones)
      # use 'Baseboard district hot water' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'DistrictHeating', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)

    when 'PSZAC_DCW_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = nil, cl = 'DistrictCooling', system_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'PSZAC_DCW_BoilerBaseboard'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = nil, cl = 'DistrictCooling', system_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'PSZAC_DCW_GasHeaters'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = nil, cl = 'DistrictCooling', system_zones)
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'PSZAC_DCW_ElectricCoil'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = 'Electricity', cl = 'DistrictCooling', system_zones)
      # use 'Baseboard electric' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_DCW_GasCoil'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = 'NaturalGas', cl = 'DistrictCooling', system_zones)
      # use 'Baseboard electric' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_DCW_Boiler'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = 'NaturalGas', znht = nil, cl = 'DistrictCooling', system_zones)
      # use 'Baseboard gas boiler' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_DCW_ASHP'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = 'AirSourceHeatPump', znht = nil, cl = 'DistrictCooling', system_zones)
      # use 'Baseboard central air source heat pump' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'AirSourceHeatPump', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_DCW_DHW'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = 'DistrictHeating', znht = nil, cl = 'DistrictCooling', system_zones)
      # use 'Baseboard district hot water' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'DistrictHeating', znht = nil, cl = nil, heated_only_zones)

    when 'PSZAC_DCW'
      standard.model_add_hvac_system(self, 'PSZ-AC', ht = nil, znht = nil, cl = 'DistrictCooling', cooled_zones)

    when 'PSZHP'
      standard.model_add_hvac_system(self, 'PSZ-HP', ht = 'Electricity', znht = nil, cl = 'Electricity', system_zones)
      # use 'Baseboard electric' for heated only zones
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_only_zones)

    # PVAV systems by default use a DX coil for cooling
    when 'PVAV_Boiler'
      standard.model_add_hvac_system(self, 'PVAV Reheat', ht = 'NaturalGas', znht = 'NaturalGas', cl = 'Electricity', zones)

    when 'PVAV_ASHP'
      standard.model_add_hvac_system(self, 'PVAV Reheat', ht = 'AirSourceHeatPump', znht = 'AirSourceHeatPump', cl = 'Electricity', zones)

    when 'PVAV_DHW'
      standard.model_add_hvac_system(self, 'PVAV Reheat', ht = 'DistrictHeating', znht = 'DistrictHeating', cl = 'Electricity', zones)

    when 'PVAV_PFP'
      standard.model_add_hvac_system(self, 'PVAV PFP Boxes', ht = 'Electricity', znht = 'Electricity', cl = 'Electricity', zones)

    when 'PVAV_BoilerElectricReheat'
      standard.model_add_hvac_system(self, 'PVAV Reheat', ht = 'Gas', znht = 'Electricity', cl = 'Electricity', zones)

    # all residential systems do not have ventilation
    when 'ResidentialAC_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'Residential AC', ht = nil, znht = nil, cl = nil, cooled_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'ResidentialAC_BoilerBaseboard'
      standard.model_add_hvac_system(self, 'Residential AC', ht = nil, znht = nil, cl = nil, cooled_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'ResidentialAC_ASHPBaseboard'
      standard.model_add_hvac_system(self, 'Residential AC', ht = nil, znht = nil, cl = nil, cooled_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'AirSourceHeatPump', znht = nil, cl = nil, heated_zones)

    when 'ResidentialAC_DHWBaseboard'
      standard.model_add_hvac_system(self, 'Residential AC', ht = nil, znht = nil, cl = nil, cooled_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'DistrictHeating', znht = nil, cl = nil, heated_zones)

    when 'ResidentialAC_ResidentialFurnace'
      standard.model_add_hvac_system(self, 'Residential Forced Air Furnace with AC', ht = nil, znht = nil, cl = nil, zones)

    when 'ResidentialAC'
      standard.model_add_hvac_system(self, 'Residential AC', ht = nil, znht = nil, cl = nil, cooled_zones)

    when 'ResidentialHP'
      standard.model_add_hvac_system(self, 'Residential Air Source Heat Pump', ht = 'Electricity', znht = nil, cl = 'Electricity', zones)

    when 'ResidentialHPNoCool'
      standard.model_add_hvac_system(self, 'Residential Air Source Heat Pump', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'ResidentialFurnace'
      standard.model_add_hvac_system(self, 'Residential Forced Air Furnace', ht = 'NaturalGas', znht = nil, cl = nil, zones)

    when 'VAV_Chiller_Boiler'
      standard.model_add_hvac_system(self, 'VAV Reheat', ht = 'NaturalGas', znht = 'NaturalGas', cl = 'Electricity', zones)

    when 'VAV_Chiller_ASHP'
      standard.model_add_hvac_system(self, 'VAV Reheat', ht = 'AirSourceHeatPump', znht = 'AirSourceHeatPump', cl = 'Electricity', zones)

    when 'VAV_Chiller_DHW'
      standard.model_add_hvac_system(self, 'VAV Reheat', ht = 'DistrictHeating', znht = 'DistrictHeating', cl = 'Electricity', zones)

    when 'VAV_Chiller_PFP'
      standard.model_add_hvac_system(self, 'VAV PFP Boxes', ht = 'NaturalGas', znht = 'NaturalGas', cl = 'Electricity', zones)

    when 'VAV_Chiller_GasCoil'
      standard.model_add_hvac_system(self, 'VAV Gas Reheat', ht = 'NaturalGas', ht = 'NaturalGas', cl = 'Electricity', zones)

    when 'VAV_ACChiller_Boiler'
      standard.model_add_hvac_system(self, 'VAV Reheat', ht = 'NaturalGas', znht = 'NaturalGas', cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')

    when 'VAV_ACChiller_ASHP'
      standard.model_add_hvac_system(self, 'VAV Reheat', ht = 'AirSourceHeatPump', znht = 'AirSourceHeatPump', cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')

    when 'VAV_ACChiller_DHW'
      standard.model_add_hvac_system(self, 'VAV Reheat', ht = 'DistrictHeating', znht = 'DistrictHeating', cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')

    when 'VAV_ACChiller_PFP'
      standard.model_add_hvac_system(self, 'VAV PFP Boxes', ht = 'NaturalGas', znht = 'NaturalGas', cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')

    when 'VAV_ACChiller_GasCoil'
      standard.model_add_hvac_system(self, 'VAV Gas Reheat', ht = 'NaturalGas', ht = 'NaturalGas', cl = 'Electricity', zones,
                                     chilled_water_loop_cooling_type: 'AirCooled')

    when 'VAV_DCW_Boiler'
      standard.model_add_hvac_system(self, 'VAV Reheat', ht = 'NaturalGas', znht = 'NaturalGas', cl = 'DistrictCooling', zones)

    when 'VAV_DCW_ASHP'
      standard.model_add_hvac_system(self, 'VAV Reheat', ht = 'AirSourceHeatPump', znht = 'AirSourceHeatPump', cl = 'DistrictCooling', zones)

    when 'VAV_DCW_DHW'
      standard.model_add_hvac_system(self, 'VAV Reheat', ht = 'DistrictHeating', znht = 'DistrictHeating', cl = 'DistrictCooling', zones)

    when 'VAV_DCW_PFP'
      standard.model_add_hvac_system(self, 'VAV PFP Boxes', ht = 'NaturalGas', znht = 'NaturalGas', cl = 'DistrictCooling', zones)

    when 'VAV_DCW_GasCoil'
      standard.model_add_hvac_system(self, 'VAV Gas Reheat', ht = 'NaturalGas', ht = 'NaturalGas', cl = 'DistrictCooling', zones)

    when 'VRF'
      standard.model_add_hvac_system(self, 'VRF', ht = 'Electricity', znht = nil, cl = 'Electricity', zones)

    when 'WSHP_FluidCooler_Boiler'
      standard.model_add_hvac_system(self, 'Water Source Heat Pumps', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones,
                                     heat_pump_loop_cooling_type: 'FluidCooler')

    when 'WSHP_CoolingTower_Boiler'
      standard.model_add_hvac_system(self, 'Water Source Heat Pumps', ht = 'NaturalGas', znht = nil, cl = 'Electricity', zones,
                                     heat_pump_loop_cooling_type: 'CoolingTower')

    when 'WSHP_GSHP'
      standard.model_add_hvac_system(self, 'Ground Source Heat Pumps', ht = 'Electricity', znht = nil, cl = 'Electricity', zones)

    when 'WSHP_DCW_DHW'
      standard.model_add_hvac_system(self, 'Water Source Heat Pumps', ht = 'DistrictHeating', znht = nil, cl = 'DistrictCooling', zones)

    when 'WindowAC_ElectricBaseboard'
      standard.model_add_hvac_system(self, 'Window AC', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'Electricity', znht = nil, cl = nil, heated_zones)

    when 'WindowAC_BoilerBaseboard'
      standard.model_add_hvac_system(self, 'Window AC', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'WindowAC_ASHPBaseboard'
      standard.model_add_hvac_system(self, 'Window AC', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'AirSourceHeatPump', znht = nil, cl = nil, heated_zones)

    when 'WindowAC_DHWBaseboard'
      standard.model_add_hvac_system(self, 'Window AC', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)
      standard.model_add_hvac_system(self, 'Baseboards', ht = 'DistrictHeating', znht = nil, cl = nil, heated_zones)

    when 'WindowAC_Furnace'
      standard.model_add_hvac_system(self, 'Window AC', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)
      standard.model_add_hvac_system(self, 'Forced Air Furnace', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'WindowAC_GasHeaters'
      standard.model_add_hvac_system(self, 'Window AC', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)
      standard.model_add_hvac_system(self, 'Unit Heaters', ht = 'NaturalGas', znht = nil, cl = nil, heated_zones)

    when 'WindowAC'
      standard.model_add_hvac_system(self, 'Window AC', ht = nil, znht = nil, cl = 'Electricity', cooled_zones)

    else
      puts "HVAC system type '#{system_type}' not recognized"

    end
  end
end

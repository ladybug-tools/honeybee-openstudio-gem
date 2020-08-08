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

require 'openstudio-standards'
require_relative 'Model.hvac'

require 'from_honeybee/extension'
require 'from_honeybee/model_object'

module FromHoneybee
  class TemplateHVAC < ModelObject
    attr_reader :errors, :warnings

    @@all_air_types = ['VAV', 'PVAV', 'PSZ', 'PTAC', 'ForcedAirFurnace']
    @@doas_types = ['FCUwithDOAS', 'WSHPwithDOAS', 'VRFwithDOAS']
    @@heat_cool_types = ['FCU', 'WSHP', 'VRF', 'Baseboard',  'EvaporativeCooler',
                         'Residential', 'WindowAC', 'GasUnitHeater']
    @@types = @@all_air_types + @@doas_types + @@heat_cool_types

    def initialize(hash = {})
      super(hash)
    end

    def self.types
      # array of all supported template HVAC systems
      @@types
    end

    def self.all_air_types
      # array of the All Air HVAC types
      @@all_air_types
    end

    def self.doas_types
      # array of the DOAS HVAC types
      @@doas_types
    end

    def self.heat_cool_types
      # array of the system types providing heating and cooling only
      @@heat_cool_types
    end
  
    def defaults(system_type)
      @@schema[:components][:schemas][system_type.to_sym][:properties]
    end

    def to_openstudio(openstudio_model, room_ids)
      # get the defaults for the specific system type
      hvac_defaults = defaults(@hash[:type])

      # make the standard applier
      if @hash[:vintage]
        standard = Standard.build(@hash[:vintage])
      else
        standard = Standard.build(hvac_defaults[:vintage][:default])
      end

      # get the default equipment type
      if @hash[:equipment_type]
        equipment_type = @hash[:equipment_type]
      else
        equipment_type = hvac_defaults[:equipment_type][:default]
      end

      # get all of the thermal zones from the Model using the room identifiers
      zones = []
      room_ids.each do |room_id|
        zone_get = openstudio_model.getThermalZoneByName(room_id)
        unless zone_get.empty?
          os_thermal_zone = zone_get.get
          zones << os_thermal_zone
        end
      end

      # create the HVAC system and assign the display name to the air loop name if it exists
      os_hvac = openstudio_model.add_cbecs_hvac_system(standard, equipment_type, zones)
      os_air_loop = nil
      air_loops = openstudio_model.getAirLoopHVACs
      unless air_loops.length == $air_loop_count  # check if any new loops were added
        $air_loop_count = air_loops.length
        os_air_loop = air_loops[-1]
        loop_name = os_air_loop.name
        unless loop_name.empty?
          if @hash[:display_name]
            os_air_loop.setName(@hash[:display_name] + ' - ' + loop_name.get)
          end
        end
      end

      # TODO: consider adding the ability to decentralize the plant by changing loop names
      #os_hvac.each do |hvac_loop|
      #  loop_name = hvac_loop.name
      #  unless loop_name.empty?
      #    hvac_loop.setName(@hash[:identifier] + ' - ' + loop_name.get)
      #  end
      #end

      # assign the economizer type if there's an air loop and the economizer is specified
      if @hash[:economizer_type] && @hash[:economizer_type] != 'Inferred' && os_air_loop
        oasys = os_air_loop.airLoopHVACOutdoorAirSystem
        unless oasys.empty?
            os_oasys = oasys.get
            oactrl = os_oasys.getControllerOutdoorAir
            oactrl.setEconomizerControlType(@hash[:economizer_type])
        end
      end

      # set the sensible heat recovery if there's an air loop and the heat recovery is specified
      if @hash[:sensible_heat_recovery] && @hash[:sensible_heat_recovery] != {:type => 'Autosize'} && os_air_loop
        erv = get_existing_erv(os_air_loop)
        unless erv
          erv = create_erv(openstudio_model, os_air_loop)
        end
        eff_at_max = @hash[:sensible_heat_recovery] * (0.76 / 0.81)  # taken from OpenStudio defaults
        erv.setSensibleEffectivenessat100CoolingAirFlow(eff_at_max)
        erv.setSensibleEffectivenessat100HeatingAirFlow(eff_at_max)
        erv.setSensibleEffectivenessat75CoolingAirFlow(@hash[:sensible_heat_recovery])
        erv.setSensibleEffectivenessat75HeatingAirFlow(@hash[:sensible_heat_recovery])
      end

      # set the latent heat recovery if there's an air loop and the heat recovery is specified
      if @hash[:latent_heat_recovery] && @hash[:latent_heat_recovery] != {:type => 'Autosize'} && os_air_loop
        erv = get_existing_erv(os_air_loop)
        unless erv
          erv = create_erv(openstudio_model, os_air_loop)
        end
        eff_at_max = @hash[:latent_heat_recovery] * (0.68 / 0.73)  # taken from OpenStudio defaults
        erv.setLatentEffectivenessat100CoolingAirFlow(eff_at_max)
        erv.setLatentEffectivenessat100HeatingAirFlow(eff_at_max)
        erv.setLatentEffectivenessat75CoolingAirFlow(@hash[:latent_heat_recovery])
        erv.setLatentEffectivenessat75HeatingAirFlow(@hash[:latent_heat_recovery])
      end

      os_hvac
    end

    def get_existing_erv(os_air_loop)
      # get an existing heat ecovery unit from an air loop; will be nil if there is none
      os_air_loop.oaComponents.each do |supply_component|
        if not supply_component.to_HeatExchangerAirToAirSensibleAndLatent.empty?
          erv = supply_component.to_HeatExchangerAirToAirSensibleAndLatent.get
          return erv
        end
      end
      nil
    end

    def create_erv(model, os_air_loop)
      # create a heat recovery unit with default zero efficiencies
      heat_ex = OpenStudio::Model::HeatExchangerAirToAirSensibleAndLatent.new(model)
      heat_ex.setEconomizerLockout(false)
      heat_ex.setName(@hash[:identifier] + '_Heat Recovery Unit')
      heat_ex.setSensibleEffectivenessat100CoolingAirFlow(0)
      heat_ex.setSensibleEffectivenessat100HeatingAirFlow(0)
      heat_ex.setSensibleEffectivenessat75CoolingAirFlow(0)
      heat_ex.setSensibleEffectivenessat75HeatingAirFlow(0)
      heat_ex.setLatentEffectivenessat100CoolingAirFlow(0)
      heat_ex.setLatentEffectivenessat100HeatingAirFlow(0)
      heat_ex.setLatentEffectivenessat75CoolingAirFlow(0)
      heat_ex.setLatentEffectivenessat75HeatingAirFlow(0)

      # add the heat exchanger to the air loop
      outdoor_node = os_air_loop.reliefAirNode
      unless outdoor_node.empty?
        os_outdoor_node = outdoor_node.get
        heat_ex.addToNode(os_outdoor_node)
      end
      heat_ex
    end

  end #TemplateHVAC
end #FromHoneybee

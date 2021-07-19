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

require 'honeybee/hvac/template'

require 'to_openstudio/model_object'

module Honeybee
  class TemplateHVAC
    @@vintage_mapper = {
      DOE_Ref_Pre_1980: 'DOE Ref Pre-1980',
      DOE_Ref_1980_2004: 'DOE Ref 1980-2004',
      ASHRAE_2004: '90.1-2004',
      ASHRAE_2007: '90.1-2007',
      ASHRAE_2010: '90.1-2010',
      ASHRAE_2013: '90.1-2013',
      ASHRAE_2016: '90.1-2016',
      ASHRAE_2019: '90.1-2019'
    }

    def to_openstudio(openstudio_model, room_ids)

      # only load openstudio-standards when needed
      require 'openstudio-standards'
      require_relative 'Model.hvac'

      # get the defaults for the specific system type
      hvac_defaults = defaults(@hash[:type])

      # make the standard applier
      if @hash[:vintage]
        standard = Standard.build(@@vintage_mapper[@hash[:vintage].to_sym])
      else
        standard = Standard.build(@@vintage_mapper[hvac_defaults[:vintage][:default].to_sym])
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
        os_air_terminal = zones[0].airLoopHVACTerminal
        unless os_air_terminal.empty?
          os_air_terminal = os_air_terminal.get
          os_air_loop_opt = os_air_terminal.airLoopHVAC
          unless os_air_loop_opt.empty?
            os_air_loop = os_air_loop_opt.get
            loop_name = os_air_loop.name
            unless loop_name.empty?
              # set the name of the air loop to align with the HVAC name
              if @hash[:display_name]
                clean_name = @hash[:display_name].to_s.gsub(/[^.A-Za-z0-9_-] /, " ")
                os_air_loop.setName(clean_name + ' - ' + loop_name.get)
              end
            end
          end
        end
      end

      # assign the economizer type if there's an air loop and the economizer is specified
      if @hash[:economizer_type] && os_air_loop
        oasys = os_air_loop.airLoopHVACOutdoorAirSystem
        unless oasys.empty?
          os_oasys = oasys.get
          oactrl = os_oasys.getControllerOutdoorAir
          oactrl.setEconomizerControlType(@hash[:economizer_type])
        end
      end

      # set the sensible heat recovery if there's an air loop and the heat recovery is specified
      if @hash[:sensible_heat_recovery] && @hash[:sensible_heat_recovery] != 0 && os_air_loop
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
      if @hash[:latent_heat_recovery] && @hash[:latent_heat_recovery] != 0 && os_air_loop
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

      # assign demand controlled ventilation if there's an air loop
      if @hash[:demand_controlled_ventilation] && os_air_loop
        oasys = os_air_loop.airLoopHVACOutdoorAirSystem
        unless oasys.empty?
          os_oasys = oasys.get
          oactrl = os_oasys.getControllerOutdoorAir
          vent_ctrl = oactrl.controllerMechanicalVentilation
          vent_ctrl.setDemandControlledVentilationNoFail(true)
          oactrl.resetMinimumFractionofOutdoorAirSchedule
        end
      end

      # assign the DOAS availability schedule if there's an air loop and it is specified
      if @hash[:doas_availability_schedule] && os_air_loop
        schedule = openstudio_model.getScheduleByName(@hash[:doas_availability_schedule])
        unless schedule.empty?
          avail_sch = schedule.get
          os_air_loop.setAvailabilitySchedule(avail_sch)
        end
      end

      # set the outdoor air controller to respect room-level ventilation schedules if they exist
      if os_air_loop
        oasys = os_air_loop.airLoopHVACOutdoorAirSystem
        unless oasys.empty?
          os_oasys = oasys.get
          oactrl = os_oasys.getControllerOutdoorAir
          oa_sch, oa_sch_name = nil, nil
          zones.each do |zone|
            oa_spec = zone.spaces[0].designSpecificationOutdoorAir
            unless oa_spec.empty?
              oa_spec = oa_spec.get
              space_oa_sch = oa_spec.outdoorAirFlowRateFractionSchedule
              unless space_oa_sch.empty?
                space_oa_sch = space_oa_sch.get
                space_oa_sch_name = space_oa_sch.name
                unless space_oa_sch_name.empty?
                  space_oa_sch_name = space_oa_sch_name.get
                  if oa_sch_name.nil? || space_oa_sch_name == oa_sch_name
                    oa_sch, oa_sch_name = space_oa_sch, space_oa_sch_name
                  else
                    oa_sch = nil
                  end
                end
              end
            end
          end
          if oa_sch
            oactrl.resetMinimumFractionofOutdoorAirSchedule
            oactrl.setMinimumOutdoorAirSchedule(oa_sch)
          end
        end
      end

      # if the systems are PTAC and there is ventilation, ensure the system includes it
      if equipment_type.include?('PTAC') || equipment_type.include?('PTHP')
        always_on = openstudio_model.getScheduleByName('Always On').get
        zones.each do |zone|
          # check if the space type has ventilation assigned to it
          out_air = zone.spaces[0].designSpecificationOutdoorAir
          unless out_air.empty?
            # get any ventilation schedules
            vent_sched = always_on
            out_air = out_air.get
            air_sch = out_air.outdoorAirFlowRateFractionSchedule
            unless air_sch.empty?
              vent_sched = air_sch.get
            end
            # get the PTAC object
            ptac = nil
            zone.equipment.each do |equip|
              e_name = equip.name
              unless e_name.empty?
                e_name = e_name.get
                if e_name.include? 'PTAC'
                  ptac = openstudio_model.getZoneHVACPackagedTerminalAirConditioner(equip.handle)
                elsif e_name.include? 'PTHP'
                  ptac = openstudio_model.getZoneHVACPackagedTerminalHeatPump(equip.handle)
                end
              end
            end
            # assign the schedule to the PTAC object
            unless ptac.nil? || ptac.empty?
              ptac = ptac.get
              ptac.setSupplyAirFanOperatingModeSchedule(vent_sched)
            end
          end
        end
      end

      # assign an electric humidifier if there's an air loop and the zones have a humidistat
      if os_air_loop
        humidistat_exists = false
        zones.each do |zone|
          h_stat = zone.zoneControlHumidistat
          unless h_stat.empty?
            humidistat_exists = true
          end
        end
        if humidistat_exists
          humidifier = create_humidifier(openstudio_model, os_air_loop)
        end
      end

      # set all plants to non-coincident sizing to avoid simualtion control issues on design days
      openstudio_model.getPlantLoops.each do |loop|
        sizing = loop.sizingPlant
        sizing.setSizingOption('NonCoincident')
      end

      os_hvac
    end

  private

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

    def create_humidifier(model, os_air_loop)
      # create an electric humidifier
      humidifier = OpenStudio::Model::HumidifierSteamElectric.new(model)
      humidifier.setName(@hash[:identifier] + '_Humidifier Unit')
      humid_controller = OpenStudio::Model::SetpointManagerMultiZoneHumidityMinimum.new(model)
      humid_controller.setName(@hash[:identifier] + '_Humidifier Controller')

      # add the humidifier to the air loop
      supply_node = os_air_loop.supplyOutletNode
      humidifier.addToNode(supply_node)
      humid_controller.addToNode(supply_node)

      humidifier
    end

  end #TemplateHVAC
end #Honeybee

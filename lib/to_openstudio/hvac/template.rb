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
      require_relative 'radiant'

      # get the defaults for the specific system type
      hvac_defaults = defaults(@hash[:type])

      # make the standard applier
      if @hash[:vintage]
        standard_id = @@vintage_mapper[@hash[:vintage].to_sym]
      else
        standard_id = @@vintage_mapper[hvac_defaults[:vintage][:default].to_sym]
      end
      standard = Standard.build(standard_id)

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

      # create the HVAC system
      doas_type = 'DOAS'
      if @hash[:demand_controlled_ventilation]
        doas_type = 'DOAS with DCV'
      end
      if equipment_type.to_s.include? 'Radiant'
        os_hvac = openstudio_model.add_radiant_hvac_system(standard, equipment_type.to_s, zones, @hash)
      else
        os_hvac = openstudio_model.add_cbecs_hvac_system(standard, equipment_type, zones, doas_type)
      end

      # Get the air loops and assign the display name to the air loop name if it exists
      os_air_loops = []
      unless equipment_type.to_s.include? 'Furnace'
        air_loops = openstudio_model.getAirLoopHVACs
        unless air_loops.length == $air_loop_count
          $air_loop_count = air_loops.length
          zones.each do |zon|
            os_air_terminal = zon.airLoopHVACTerminal
            unless os_air_terminal.empty?
              os_air_terminal = os_air_terminal.get
              os_air_loop_opt = os_air_terminal.airLoopHVAC
              unless os_air_loop_opt.empty?
                os_air_loop = os_air_loop_opt.get
                os_air_loops << os_air_loop
                loop_name = os_air_loop.name
                unless loop_name.empty?
                  # set the name of the air loop to align with the HVAC name
                  if @hash[:display_name]
                    clean_name = @hash[:display_name].to_s.gsub(/[^.A-Za-z0-9_-] /, " ")
                    os_air_loop.setName(clean_name + ' - ' + loop_name.get)
                  end
                end
                break if !equipment_type.include? 'PSZ'  # multiple air loops have been added
              end
            end
          end
        end
      end

      # set the efficiencies of fans to be reasonable for DOAS vs. All-Air loops
      if !os_air_loops.empty?
        if equipment_type.to_s.include? 'DOAS'
          fan_size = 0.2
        else
          fan_size = 2
        end
        os_air_loops.each do |os_air_loop|
          # set the supply fan efficiency
          unless os_air_loop.supplyFan.empty?
            s_fan = os_air_loop.supplyFan.get
            s_fan = fan_from_component(s_fan)
            unless s_fan.nil?
              s_fan.setMaximumFlowRate(fan_size)  # set to a typical value
              standard.fan_apply_standard_minimum_motor_efficiency(
                s_fan, standard.fan_brake_horsepower(s_fan))
              s_fan.autosizeMaximumFlowRate()  # set it back to autosize
            end
          end
          # set the return fan efficiency
          unless os_air_loop.returnFan.empty?
            ex_fan = os_air_loop.returnFan.get
            ex_fan = fan_from_component(ex_fan)
            unless ex_fan.nil?
              ex_fan.setMaximumFlowRate(fan_size)  # set to a typical value
              standard.fan_apply_standard_minimum_motor_efficiency(
                ex_fan, standard.fan_brake_horsepower(ex_fan))
              ex_fan.autosizeMaximumFlowRate()  # set it back to autosize
            end
          end
        end
      end

      # get the boilers and assign a reasonable efficiency (assuming 40kW boilers)
      if equipment_type.to_s.include? 'Boiler'
        openstudio_model.getBoilerHotWaters.sort.each do |obj|
          obj.setNominalCapacity(40000)  # set to a typical value
          standard.boiler_hot_water_apply_efficiency_and_curves(obj)
          obj.autosizeNominalCapacity()  # set it back to autosize
          obj.setName(standard_id + ' Boiler')
        end
      end

      # get the chillers and assign a reasonable COP (assuming 2000kW water-cooled; 600kW air-cooled)
      if equipment_type.to_s.include? 'Chiller'
        if equipment_type.to_s.include? 'ACChiller'
          chiller_size = 600000
        else
          chiller_size = 2000000
        end
        clg_tower_objs = openstudio_model.getCoolingTowerSingleSpeeds
        openstudio_model.getChillerElectricEIRs.sort.each do |obj|
          obj.setReferenceCapacity(chiller_size)  # set to a typical value
          if obj.name.empty?
            obj_name = standard_id + ' Chiller'
          else
            obj_name = obj.name.get
          end
          standard.chiller_electric_eir_apply_efficiency_and_curves(obj, clg_tower_objs)
          obj.autosizeReferenceCapacity()  # set it back to autosize
          obj.setName(obj_name)
        end
      end

      # set the efficiency of any gas heaters (assuming 10kW heaters)
      if equipment_type.to_s.include? 'GasHeaters'
        zones.each do |zon|
          zon.equipment.each do |equp|
            if !equp.to_ZoneHVACUnitHeater.empty?
              unit_heater = equp.to_ZoneHVACUnitHeater.get
              coil = unit_heater.heatingCoil
              unless coil.to_CoilHeatingGas.empty?
                coil = coil.to_CoilHeatingGas.get
                coil.setNominalCapacity(10000)  # set to a typical value
                standard.coil_heating_gas_apply_efficiency_and_curves(coil)
                coil.autosizeNominalCapacity()  # set it back to autosize
              end
            end
          end
        end
      end

      # change furnace to electric if specified
      if equipment_type.to_s.include? 'Furnace_Electric'
        openstudio_model.getAirLoopHVACUnitarySystems.sort.each do |obj|
          unless obj.heatingCoil.empty?
            old_coil = obj.heatingCoil.get
            heat_coil = OpenStudio::Model::CoilHeatingElectric.new(openstudio_model)
            unless old_coil.name.empty?
              heat_coil.setName(old_coil.name.get)
            end
            obj.setHeatingCoil(heat_coil)
            old_coil.remove()
          end
        end
      end

      # assign the economizer type if there's an air loop and the economizer is specified
      if @hash[:economizer_type] && !os_air_loops.empty?
        os_air_loops.each do |os_air_loop|
          oasys = os_air_loop.airLoopHVACOutdoorAirSystem
          unless oasys.empty?
            os_oasys = oasys.get
            oactrl = os_oasys.getControllerOutdoorAir
            oactrl.setEconomizerControlType(@hash[:economizer_type])
          end
        end
      end

      # set the sensible heat recovery if there's an air loop and the heat recovery is specified
      if @hash[:sensible_heat_recovery] && @hash[:sensible_heat_recovery] != 0 && !os_air_loops.empty?
        os_air_loops.each do |os_air_loop|
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
      end

      # set the latent heat recovery if there's an air loop and the heat recovery is specified
      if @hash[:latent_heat_recovery] && @hash[:latent_heat_recovery] != 0 && !os_air_loops.empty?
        os_air_loops.each do |os_air_loop|
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
      end

      # assign demand controlled ventilation if there's an air loop
      if @hash[:demand_controlled_ventilation] && !os_air_loops.empty?
        if !equipment_type.to_s.include? 'DOAS'
          os_air_loops.each do |os_air_loop|
            oasys = os_air_loop.airLoopHVACOutdoorAirSystem
            unless oasys.empty?
              os_oasys = oasys.get
              oactrl = os_oasys.getControllerOutdoorAir
              vent_ctrl = oactrl.controllerMechanicalVentilation
              vent_ctrl.setDemandControlledVentilationNoFail(true)
              oactrl.resetMinimumFractionofOutdoorAirSchedule
            end
          end
        end
      end
      
      unless os_air_loops.empty?
        # have an always available schedule ready to use if there are no user controls
        always_avail_name = 'Building HVAC Always Available'
        schedule = openstudio_model.getScheduleByName(always_avail_name)
        unless schedule.empty?
          always_avail = schedule.get
        else
          always_avail = OpenStudio::Model::ScheduleRuleset.new(openstudio_model)
          always_avail.setName(always_avail_name)
          def_day_sch = always_avail.defaultDaySchedule
          time_until = OpenStudio::Time.new(0, 24, 0, 0)
          def_day_sch.addValue(time_until, 1)
        end

        # assign the DOAS availability schedule if there's an air loop and it is specified
        avail_sch = nil
        if @hash[:doas_availability_schedule]
          schedule = openstudio_model.getScheduleByName(@hash[:doas_availability_schedule])
          unless schedule.empty?
            avail_sch = schedule.get
          end
        end
        unless avail_sch
          avail_sch = always_avail
        end
        os_air_loops.each do |os_air_loop|
          os_air_loop.setAvailabilitySchedule(avail_sch)
        end

        # set the outdoor air controller to respect room-level ventilation schedules if they exist
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
        unless oa_sch
          oa_sch = always_avail
        end
        
        os_air_loops.each do |os_air_loop|
          oasys = os_air_loop.airLoopHVACOutdoorAirSystem
          unless oasys.empty?
            os_oasys = oasys.get
            oactrl = os_oasys.getControllerOutdoorAir
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
      if !os_air_loops.empty?
        humidistat_exists = false
        zones.each do |zone|
          h_stat = zone.zoneControlHumidistat
          unless h_stat.empty?
            humidistat_exists = true
            if equipment_type.to_s.include? 'DOAS'
              z_sizing = zone.sizingZone
              z_sizing.setDedicatedOutdoorAirSystemControlStrategy('NeutralDehumidifiedSupplyAir')
            end
          end
        end
        if humidistat_exists
          os_air_loops.each do |os_air_loop|
            humidifier = create_humidifier(openstudio_model, os_air_loop)
          end
        end
      end

    end

  private

    def fan_from_component(fan_component)
      # get a detailed fan object from a generic fan HVAC component; will be nil if it's not a fan
      if !fan_component.to_FanVariableVolume.empty?
        return fan_component.to_FanVariableVolume.get
      elsif !fan_component.to_FanConstantVolume.empty?
        return fan_component.to_FanConstantVolume.get
      elsif !fan_component.to_FanOnOff.empty?
        return fan_component.to_FanOnOff.get
      end
      nil
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

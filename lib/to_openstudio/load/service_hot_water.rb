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

require 'honeybee/load/service_hot_water'

require 'to_openstudio/model_object'

module Honeybee
  class ServiceHotWaterAbridged
    @@max_target_temp = 60
    @@max_temp_schedule = nil
    @@shw_connections = {}
    @@shw_rates = {}
    @@hp_deadband = 4
    @@sys_count = 1

    def shw_connections
      @@shw_connections
    end

    def find_existing_openstudio_object(openstudio_model)
      model_shw = openstudio_model.getWaterUseEquipmentByName(@hash[:identifier])
      return model_shw.get unless model_shw.empty?
      nil
    end

    def add_hot_water_plants(openstudio_model, shw_hashes)
      # add district hot water loops to supply all of the shw_connections
      shw_hashes.each do |shw_hash|
        unless @@shw_rates[shw_hash[:identifier]].nil?
          # create the plant loop
          hot_water_plant = OpenStudio::Model::PlantLoop.new(openstudio_model)
          hot_water_plant.setName('SHW Loop ' + shw_hash[:identifier])
          hot_water_plant.setMaximumLoopTemperature(@@max_target_temp)
          hot_water_plant.setMinimumLoopTemperature(10)  # default value in C from OpenStudio Application

          # edit the sizing information to be for a hot water loop
          loop_sizing = hot_water_plant.sizingPlant()
          loop_sizing.setLoopType('Heating')
          loop_sizing.setDesignLoopExitTemperature(@@max_target_temp)  
          loop_sizing.setLoopDesignTemperatureDifference(5)  # default value in C from OpenStudio Application

          # add a setpoint manager for the loop
          hot_sch = @@max_temp_schedule
          if @@max_temp_schedule.nil?
            hot_sch_name = @@max_target_temp.to_s + 'C Hot Water'
            hot_sch = create_constant_schedule(openstudio_model, hot_sch_name, @@max_target_temp)
          end
          sp_manager = OpenStudio::Model::SetpointManagerScheduled.new(openstudio_model, hot_sch)
          sp_manager.addToNode(hot_water_plant.supplyOutletNode())

          # add a constant speed pump for the loop
          hot_water_pump = OpenStudio::Model::PumpConstantSpeed.new(openstudio_model)
          hot_water_pump.setName('SHW Pump' + @@sys_count.to_s)
          hot_water_pump.setRatedPumpHead(29891)  # default value in Pa from OpenStudio Application
          hot_water_pump.setMotorEfficiency(0.9)  # default value from OpenStudio Application
          hot_water_pump.addToNode(hot_water_plant.supplyInletNode())

          eq_type = shw_hash[:equipment_type]
          if eq_type == 'Default_District_SHW'
            # add a district heating system to supply the heat for the loop
            district_hw = OpenStudio::Model::WaterHeaterMixed.new(openstudio_model)
            district_hw.setName('Ideal Service Hot Water Heater')
            district_hw.setHeaterFuelType('DistrictHeating')
            district_hw.setOffCycleParasiticFuelType('DistrictHeating')
            district_hw.setOnCycleParasiticFuelType('DistrictHeating')
            district_hw.setHeaterThermalEfficiency(1.0)
            district_hw.setHeaterMaximumCapacity(1000000)
            district_hw.setTankVolume(0)
            district_hw.setHeaterControlType('Modulate')
            target_sch_name = '22C Ambient Condition'
            target_sch = create_constant_schedule(openstudio_model, target_sch_name, 22)
            district_hw.setAmbientTemperatureSchedule(target_sch)
            district_hw.setOffCycleLossCoefficienttoAmbientTemperature(0)
            district_hw.setOnCycleLossCoefficienttoAmbientTemperature(0)
            hot_water_plant.addSupplyBranchForComponent(district_hw)
            # try to minimize the impact of the pump as much as possible
            hot_water_pump.setEndUseSubcategory('Water Systems')
            hot_water_pump.setMotorEfficiency(0.9)
          else
            # add a water heater to supply the heat for the loop
            heater = OpenStudio::Model::WaterHeaterMixed.new(openstudio_model)
            if eq_type == 'Electric_WaterHeater' || eq_type == 'HeatPump_WaterHeater' || eq_type == 'Electric_TanklessHeater'
              heater.setHeaterFuelType('Electricity')
              heater.setOffCycleParasiticFuelType('Electricity')
              heater.setOnCycleParasiticFuelType('Electricity')
            end

            # set the water heater efficiency
            if eq_type == 'HeatPump_WaterHeater'
              heater.setHeaterThermalEfficiency(1.0)
            elsif shw_hash[:heater_efficiency].nil?
              if eq_type == 'Electric_WaterHeater' || eq_type == 'Electric_TanklessHeater'
                heater.setHeaterThermalEfficiency(1.0)
              else
                heater.setHeaterThermalEfficiency(0.8)
              end
            else
              heater.setHeaterThermalEfficiency(shw_hash[:heater_efficiency])
            end

            # set the ambient condition of the water tank
            to_thermal_zone = false
            unless shw_hash[:ambient_condition].nil?
              if shw_hash[:ambient_condition].is_a? Numeric
                target_sch_name = shw_hash[:ambient_condition].to_s + 'C Ambient Condition'
                target_sch = create_constant_schedule(
                  openstudio_model, target_sch_name, shw_hash[:ambient_condition])
                heater.setAmbientTemperatureSchedule(target_sch)
              else
                source_zone_ref = openstudio_model.getThermalZoneByName(shw_hash[:ambient_condition])
                unless source_zone_ref.empty?
                  source_zone = source_zone_ref.get
                  heater.setAmbientTemperatureThermalZone(source_zone)
                end
                heater.setAmbientTemperatureIndicator('ThermalZone')
                to_thermal_zone = true
              end
            else
              target_sch_name = '22C Ambient Condition'
              target_sch = create_constant_schedule(openstudio_model, target_sch_name, 22)
              heater.setAmbientTemperatureSchedule(target_sch)
            end

            # set the ambient loss coefficient
            if to_thermal_zone
              unless shw_hash[:ambient_loss_coefficient].nil?
                heater.setOffCycleLossFractiontoThermalZone(
                  shw_hash[:ambient_loss_coefficient])
                heater.setOnCycleLossFractiontoThermalZone(
                  shw_hash[:ambient_loss_coefficient])
              else
                heater.setOffCycleLossFractiontoThermalZone(6)
                heater.setOnCycleLossFractiontoThermalZone(6)
              end
            else
              unless shw_hash[:ambient_loss_coefficient].nil?
                heater.setOffCycleLossCoefficienttoAmbientTemperature(
                  shw_hash[:ambient_loss_coefficient])
                heater.setOnCycleLossCoefficienttoAmbientTemperature(
                  shw_hash[:ambient_loss_coefficient])
              else
                heater.setOffCycleLossCoefficienttoAmbientTemperature(6)
                heater.setOnCycleLossCoefficienttoAmbientTemperature(6)
              end
            end

            # set the capactiy and and controls of the water heater
            heater.setHeaterMaximumCapacity(1000000)
            if eq_type == 'Gas_TanklessHeater' || eq_type == 'Electric_TanklessHeater'
              heater.setName('SHW Tankless WaterHeater' + @@sys_count.to_s)
              heater.setTankVolume(0)
              heater.setHeaterControlType('Modulate')
              heater.setOffCycleLossCoefficienttoAmbientTemperature(0)
              heater.setOnCycleLossCoefficienttoAmbientTemperature(0)
            else
              heater.setName('SHW WaterHeater' + @@sys_count.to_s)
              heater.setTankVolume(@@shw_rates[shw_hash[:identifier]])
            end

            # add it to the loop
            hot_water_plant.addSupplyBranchForComponent(heater)
            
            # if it's a heat pump system, then add the pump
            if eq_type == 'HeatPump_WaterHeater'
              # create a coil for the heat pump
              heat_pump = OpenStudio::Model::CoilWaterHeatingAirToWaterHeatPump.new(openstudio_model)
              heat_pump.setName('SHW HPWH DX Coil' + @@sys_count.to_s)
              if shw_hash[:heater_efficiency].nil?
                heat_pump.setRatedCOP(3.5)
              else
                heat_pump.setRatedCOP(shw_hash[:heater_efficiency])
              end

              # add a fan for the heat pump system
              fan = OpenStudio::Model::FanOnOff.new(openstudio_model)
              fan.setName('HPWH Fan' + @@sys_count.to_s)
              fan.setEndUseSubcategory('Water Systems')
              setpt_sch = create_constant_schedule(
                openstudio_model, 'HPWH Setpoint' + @@sys_count.to_s, @@max_target_temp + (@@hp_deadband * 2))
              inlet_sch = create_constant_schedule(
                openstudio_model, 'Inlet Air Mixer Fraction' + @@sys_count.to_s, 0.2)

              # add a water heater to supply the heat for the loop
              heat_sys = OpenStudio::Model::WaterHeaterHeatPump.new(
                openstudio_model, heat_pump, heater, fan, setpt_sch, inlet_sch)
              heat_sys.setDeadBandTemperatureDifference(@@hp_deadband)
              
              source_zone_ref = openstudio_model.getThermalZoneByName(shw_hash[:ambient_condition])
              unless source_zone_ref.empty?
                source_zone = source_zone_ref.get
                heat_sys.addToThermalZone(source_zone)
              end
              heat_sys.setName('SHW WaterHeater HeatPump' + @@sys_count.to_s)
            end
          end

          # add all of the water use connections to the loop and total the capacity
          @@shw_connections[shw_hash[:identifier]].each do |shw_conn|
            hot_water_plant.addDemandBranchForComponent(shw_conn)
          end
          @@sys_count = @@sys_count + 1
        end
      end
    end

    def to_openstudio(openstudio_model, os_space, shw_name)
      # create water use equipment + connection and set identifier
      os_shw_def = OpenStudio::Model::WaterUseEquipmentDefinition.new(openstudio_model)
      os_shw = OpenStudio::Model::WaterUseEquipment.new(os_shw_def)
      unique_id = @hash[:identifier] + '..' + os_space.nameString[0...-6]
      os_shw_def.setName(unique_id)
      os_shw.setName(unique_id)

      # assign the flow of water
      total_flow = (@hash[:flow_per_area].to_f * os_space.floorArea) / 3600000
      os_shw_def.setPeakFlowRate(total_flow)
      os_shw_def.setEndUseSubcategory('General')
      if @@shw_rates[shw_name].nil?
        @@shw_rates[shw_name] = 0
      end
      @@shw_rates[shw_name] = @@shw_rates[shw_name] + (total_flow * 3600)

      # assign schedule
      shw_schedule = openstudio_model.getScheduleByName(@hash[:schedule])
      unless shw_schedule.empty?
        shw_schedule_object = shw_schedule.get
        os_shw.setFlowRateFractionSchedule(shw_schedule_object)
      end

      # assign the hot water temperature
      target_temp = defaults[:target_temperature][:default]
      if @hash[:target_temperature]
        target_temp = @hash[:target_temperature]
      end
      target_sch_name = target_temp.to_s + 'C Hot Water'
      target_water_sch = create_constant_schedule(openstudio_model, target_sch_name, target_temp)
      os_shw_def.setTargetTemperatureSchedule(target_water_sch)

      # create the hot water connection with same temperature as target temperature
      os_shw_conn = OpenStudio::Model::WaterUseConnections.new(openstudio_model)
      os_shw_conn.addWaterUseEquipment(os_shw)
      os_shw_conn.setHotWaterSupplyTemperatureSchedule(target_water_sch)
      if target_temp > @@max_target_temp
        @@max_target_temp = target_temp
        @@max_temp_schedule = target_water_sch
      end
      if shw_name.nil?
        shw_name = 'default_district_shw'
      end
      if @@shw_connections[shw_name].nil?
        @@shw_connections[shw_name] = []
      end
      @@shw_connections[shw_name] << os_shw_conn

      # assign sensible fraction if it exists
      sens_fract = defaults[:sensible_fraction][:default]
      if @hash[:sensible_fraction]
        sens_fract = @hash[:sensible_fraction]
      end
      sens_sch_name = sens_fract.to_s + ' Hot Water Sensible Fraction'
      sens_fract_sch = create_constant_schedule(openstudio_model, sens_sch_name, sens_fract)
      os_shw_def.setSensibleFractionSchedule(sens_fract_sch)

      # assign latent fraction if it exists
      lat_fract = defaults[:latent_fraction][:default]
      if @hash[:latent_fraction]
        lat_fract = @hash[:latent_fraction]
      end
      lat_sch_name = lat_fract.to_s + ' Hot Water Latent Fraction'
      lat_fract_sch = create_constant_schedule(openstudio_model, lat_sch_name, lat_fract)
      os_shw_def.setLatentFractionSchedule(lat_fract_sch)

      # assign the service hot water to the space
      os_shw.setSpace(os_space)

      os_shw
    end

    private

    def create_constant_schedule(openstudio_model, schedule_name, value)
      # check if a constant schedule already exists and, if not, create it
      exist_schedule = openstudio_model.getScheduleByName(schedule_name)
      if exist_schedule.empty?  # create the schedule
        os_sch_ruleset = OpenStudio::Model::ScheduleRuleset.new(openstudio_model, value)
        os_sch_ruleset.setName(schedule_name)
      else
        os_sch_ruleset = exist_schedule.get
      end
      os_sch_ruleset
    end

  end #ServiceHotWaterAbridged
end #Honeybee

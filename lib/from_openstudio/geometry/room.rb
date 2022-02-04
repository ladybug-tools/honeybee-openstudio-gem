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

require 'honeybee/model_object'

module Honeybee
  class Room < ModelObject

    def self.from_space(space)
      hash = {}
      hash[:type] = 'Room'
      hash[:identifier] = clean_identifier(space.nameString)
      unless space.displayName.empty?
        hash[:display_name] = (space.displayName.get).force_encoding("UTF-8")
      end
      hash[:user_data] = {space: space.handle.to_s}
      hash[:properties] = properties_from_space(space)

      site_transformation = space.siteTransformation
      hash[:faces] = faces_from_space(space, site_transformation)

      indoor_shades = indoor_shades_from_space(space)
      hash[:indoor_shades] = indoor_shades if !indoor_shades.empty?

      outdoor_shades = outdoor_shades_from_space(space)
      hash[:outdoor_shades] = outdoor_shades if !outdoor_shades.empty?

      multipler = multiplier_from_space(space)
      hash[:multipler] = multipler if multipler

      story = story_from_space(space)
      hash[:story] = story if story

      hash
    end

    def self.properties_from_space(space)
      hash = {}
      hash[:type] = 'RoomPropertiesAbridged'
      hash[:energy] = self.energy_properties_from_space(space)

      hash
    end

    def self.energy_properties_from_space(space)
      hash = {}
      hash[:type] = 'RoomEnergyPropertiesAbridged'
      # set room energy properties
      unless space.defaultConstructionSet.empty?
        const_set = space.defaultConstructionSet.get
        hash[:construction_set] = const_set.nameString
      end
      unless space.spaceType.empty?
        space_type = space.spaceType.get
        hash[:program_type] = space_type.nameString
      end
      # TODO: These are loads assigned to the space directly. How should duplicates created in programtype, if any, be handled? 
      unless space.people.empty?
        space.people.each do |people|
          people_def = people.peopleDefinition
          # Only translate if people per floor area is specified
          # Check if schedule exists and is of the correct type
          if !people_def.peopleperSpaceFloorArea.empty? && !people.numberofPeopleSchedule.empty?
            sch = people.numberofPeopleSchedule.get
            if sch.to_ScheduleRuleset.is_initialized or sch.to_ScheduleFixedInterval.is_initialized
              hash[:people] = Honeybee::PeopleAbridged.from_load(people)
              break
            end
          end
        end
      end
      unless space.lights.empty?
        space.lights.each do |light|
          light_def = light.lightsDefinition
          # Only translate if watts per floor area is specified
          # Check if schedule exists and is of the correct type
          if !light_def.wattsperSpaceFloorArea.empty? && !light.schedule.empty?
            sch = light.schedule.get
            if sch.to_ScheduleRuleset.is_initialized or sch.to_ScheduleFixedInterval.is_initialized
              hash[:lighting] = Honeybee::LightingAbridged.from_load(light)
              break
            end
          end
        end
      end
      unless space.electricEquipment.empty?
        space.electricEquipment.each do |electric_eq|
          electric_eq_def = electric_eq.electricEquipmentDefinition
          # Only translate if watts per floor area is specified
          # Check if schedule exists and is of the correct type
          if !electric_eq_def.wattsperSpaceFloorArea.empty? && !electric_eq.schedule.empty?
            sch = electric_eq.schedule.get
            if sch.to_ScheduleRuleset.is_initialized or sch.to_ScheduleFixedInterval.is_initialized
              hash[:electric_equipment] = Honeybee::ElectricEquipmentAbridged.from_load(electric_eq)
              break
            end
          end
        end
      end
      unless space.gasEquipment.empty?
        space.gasEquipment.each do |gas_eq|
          gas_eq_def = gas_eq.gasEquipmentDefinition
          # Only translate if watts per floor area is specified
          # Check if schedule exists and is of the correct type
          if !gas_eq_def.wattsperSpaceFloorArea.empty? && !gas_eq.schedule.empty?
            sch = gas_eq.schedule.get
            if sch.to_ScheduleRuleset.is_initialized or sch.to_ScheduleFixedInterval.is_initialized
              hash[:gas_equipment] = Honeybee::GasEquipmentAbridged.from_load(gas_eq)
              break
            end
          end
        end
      end
      unless space.otherEquipment.empty?
        hash[:process_loads] = []
        space.otherEquipment.each do |other_eq|
          other_eq_def = other_eq.otherEquipmentDefinition
          if !other_eq_def.designLevel.empty? && !other_eq.schedule.empty?
            sch = other_eq.schedule.get
            if sch.to_ScheduleRuleset.is_initialized or sch.to_ScheduleFixedInterval.is_initialized
              hash[:process_loads] << Honeybee::ProcessAbridged.from_load(other_eq)
            end
          end
        end
      end
      unless space.spaceInfiltrationDesignFlowRates.empty?
        space.spaceInfiltrationDesignFlowRates.each do |infiltration|
          # Only translate if flow per exterior area is specified
          # Check if schedule exists and is of the correct type
          if !infiltration.flowperExteriorSurfaceArea.empty? && !infiltration.schedule.empty?
            sch = infiltration.schedule.get
            if sch.to_ScheduleRuleset.is_initialized or sch.to_ScheduleFixedInterval.is_initialized
              hash[:infiltration] = Honeybee::InfiltrationAbridged.from_load(infiltration)
              break
            end
          end
        end
      end
      unless space.designSpecificationOutdoorAir.empty?
        hash[:ventilation] = Honeybee::VentilationAbridged.from_load(space.designSpecificationOutdoorAir.get)
      end
      unless space.daylightingControls.empty?
        hash[:daylighting_control] = Honeybee::DaylightingControl.from_load(space.daylightingControls[0])
      end
      thermal_zone = space.thermalZone
      unless thermal_zone.empty?
        thermal_zone = space.thermalZone.get
        unless thermal_zone.thermostatSetpointDualSetpoint.empty?
          hash[:setpoint] = {}
          hash[:setpoint][:type] = 'SetpointAbridged'
          thermostat = thermal_zone.thermostatSetpointDualSetpoint.get
          hash[:setpoint][:identifier] = thermostat.nameString
          unless thermostat.displayName.empty?
            hash[:display_name] = (thermostat.displayName.get).force_encoding("UTF-8")
          end
          sch = thermostat.heatingSetpointTemperatureSchedule
          if sch.empty? or !sch.get.to_ScheduleRuleset.is_initialized
            # if heating setpoint schedule is not specified create a new setpoint schedule and assign to HB thermostat object.
            # first check if schedule is already created
            if $heating_setpoint_schedule.nil?
              openstudio_model = OpenStudio::Model::Model.new
              openstudio_schedule = OpenStudio::Model::ScheduleRuleset.new(openstudio_model)
              openstudio_schedule.setName('Heating Schedule Default')
              openstudio_sch_type_lim = OpenStudio::Model::ScheduleTypeLimits.new(openstudio_model)
              openstudio_sch_type_lim.setName('Temperature')
              openstudio_sch_type_lim.setNumericType('Temperature')
              openstudio_schedule.defaultDaySchedule.setName('Heating Day Default')
              openstudio_schedule.defaultDaySchedule.addValue(OpenStudio::Time.new(0,24,0,0), -100)
              openstudio_schedule.defaultDaySchedule.setScheduleTypeLimits(openstudio_sch_type_lim)
              $heating_setpoint_schedule = Honeybee::ScheduleRulesetAbridged.from_schedule_ruleset(openstudio_schedule)
            end
            hash[:setpoint][:heating_schedule] = $heating_setpoint_schedule[:identifier]
          else
            heating_schedule = sch.get
            hash[:setpoint][:heating_schedule] = heating_schedule.nameString
          end
          sch = thermostat.coolingSetpointTemperatureSchedule
          if sch.empty? or !sch.get.to_ScheduleRuleset.is_initialized
            # if cooling setpoint schedule is not specified create a new setpoint schedule and assign to HB thermostat object
            # first check if schedule is already created
            if $cooling_setpoint_schedule.nil?
              openstudio_model = OpenStudio::Model::Model.new
              openstudio_schedule = OpenStudio::Model::ScheduleRuleset.new(openstudio_model)
              openstudio_schedule.setName('Cooling Schedule Default')
              openstudio_sch_type_lim = OpenStudio::Model::ScheduleTypeLimits.new(openstudio_model)
              openstudio_sch_type_lim.setName('Temperature')
              openstudio_sch_type_lim.setNumericType('Temperature')
              openstudio_schedule.defaultDaySchedule.setName('Cooling Day Default')
              openstudio_schedule.defaultDaySchedule.addValue(OpenStudio::Time.new(0,24,0,0), 100)
              openstudio_schedule.defaultDaySchedule.setScheduleTypeLimits(openstudio_sch_type_lim)
              $cooling_setpoint_schedule = Honeybee::ScheduleRulesetAbridged.from_schedule_ruleset(openstudio_schedule)
            end
            hash[:setpoint][:cooling_schedule] = $cooling_setpoint_schedule[:identifier]
          else
            cooling_schedule = sch.get
            hash[:setpoint][:cooling_schedule] = cooling_schedule.nameString
          end
        end
        unless thermal_zone.zoneControlHumidistat.empty?
          humidistat = thermal_zone.zoneControlHumidistat.get
          unless humidistat.humidifyingRelativeHumiditySetpointSchedule.empty?
            sch = humidistat.humidifyingRelativeHumiditySetpointSchedule.get
            if sch.to_ScheduleRuleset.is_initialized or sch.to_ScheduleFixedInterval.is_initialized
              hash[:setpoint][:humidifying_schedule] = sch.nameString
            end
          end
          unless humidistat.dehumidifyingRelativeHumiditySetpointSchedule.empty?
            sch = humidistat.dehumidifyingRelativeHumiditySetpointSchedule.get
            if sch.to_ScheduleRuleset.is_initialized or sch.to_ScheduleFixedInterval.is_initialized
              hash[:setpoint][:dehumidifying_schedule] = sch.nameString
            end
          end
        end
      end 
      hash
    end

    def self.faces_from_space(space, site_transformation)
      result = []
      space.surfaces.each do |surface|
        result << Face.from_surface(surface, site_transformation)
      end
      result
    end

    def self.indoor_shades_from_space(space)
      []
    end

    def self.outdoor_shades_from_space(space)
      result = []
      space.shadingSurfaceGroups.each do |shading_surface_group|
        # skip if attached to a surface or sub_surface
        if !shading_surface_group.shadedSurface.empty? || !shading_surface_group.shadedSubSurface.empty?
          next
        end

        site_transformation = shading_surface_group.siteTransformation
        shading_surface_group.shadingSurfaces.each do |shading_surface|
          result << Shade.from_shading_surface(shading_surface, site_transformation)
        end
      end
      result
    end

    def self.multiplier_from_space(space)
      multiplier = space.multiplier
      if multiplier != 1
        return multiplier
      end
      nil
    end

    def self.story_from_space(space)
      story = space.buildingStory
      if !story.empty?
        return clean_identifier(story.get.nameString)
      end
      nil
    end

  end # Aperture
end # Honeybee

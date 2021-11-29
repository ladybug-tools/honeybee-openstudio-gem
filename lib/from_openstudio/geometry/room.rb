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
      hash[:display_name] = clean_name(space.nameString)
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
          # Only translate if people per floor area is specified
          unless people.peopleDefinition.peopleperSpaceFloorArea.empty?
            hash[:people] = Honeybee::PeopleAbridged.from_load(people)
            break
          end
        end
      end
      unless space.lights.empty?
        space.lights.each do |light|
          # Only translate if watts per floor area is specified
          unless light.lightsDefinition.wattsperSpaceFloorArea.empty?
            hash[:lighting] = Honeybee::LightingAbridged.from_load(light)
            break
          end
        end
      end
      unless space.electricEquipment.empty?
        space.electricEquipment.each do |electric_eq|
          electric_eq_def = electric_eq.electricEquipmentDefinition
          # Only translate if watts per floor area is specified
          unless electric_eq_def.wattsperSpaceFloorArea.empty?
            hash[:electric_equipment] = Honeybee::ElectricEquipmentAbridged.from_load(electric_eq)
            break
          end
        end
      end
      unless space.gasEquipment.empty?
        space.gasEquipment.each do |gas_eq|
          gas_eq_def = gas_eq.gasEquipmentDefinition
          unless gas_eq_def.wattsperSpaceFloorArea
            hash[:gas_equipment] = Honeybee::GasEquipmentAbridged.from_load(gas_eq)
            break
          end
        end
      end
      unless space.otherEquipment.empty?
        hash[:process_loads] = []
        space.otherEquipment.each do |other_eq|
          unless other_eq.designLevel.empty?
            hash[:process_loads] << Honeybee::ProcessAbridged.from_load(other_eq)
          end
        end
      end
      unless space.spaceInfiltrationDesignFlowRates.empty?
        space.spaceInfiltrationDesignFlowRates.each do |infilt|
          # Only translate if flow per exterior area is specified
          unless infilt.flowperExteriorSurfaceArea.empty?
            hash[:infiltration] = Honeybee::InfiltrationAbridged.from_load(infilt)
            break
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
        # TODO: There isn't a combined setpoint object in OS and the identifier can't be assigned.
        # For now using the thermal zone name as setpoint identifier.
          hash[:setpoint] = {}
          thermostat = thermal_zone.thermostatSetpointDualSetpoint.get
          hash[:setpoint][:identifier] = thermostat.nameString
          if thermostat.heatingSetpointTemperatureSchedule.empty?
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
              openstudio_schedule.defaultDaySchedule.addValue(OpenStudio::Time.new(0,24,0,0), 100)
              openstudio_schedule.defaultDaySchedule.setScheduleTypeLimits(openstudio_sch_type_lim)
              $heating_setpoint_schedule = Honeybee::ScheduleRulesetAbridged.from_schedule_ruleset(openstudio_schedule)
            end
            hash[:setpoint][:heating_schedule] = $heating_setpoint_schedule[:identifier]
          else
            heating_schedule = thermostat.heatingSetpointTemperatureSchedule.get
            hash[:setpoint][:heating_schedule] = heating_schedule.nameString
          end
          if thermostat.coolingSetpointTemperatureSchedule.empty?
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
              openstudio_schedule.defaultDaySchedule.addValue(OpenStudio::Time.new(0,24,0,0), -100)
              openstudio_schedule.defaultDaySchedule.setScheduleTypeLimits(openstudio_sch_type_lim)
              $cooling_setpoint_schedule = Honeybee::ScheduleRulesetAbridged.from_schedule_ruleset(openstudio_schedule)
            end
            hash[:setpoint][:cooling_schedule] = $cooling_setpoint_schedule[:identifier]
          else
            cooling_schedule = thermostat.coolingSetpointTemperatureSchedule.get
            hash[:setpoint][:cooling_schedule] = cooling_schedule.nameString
          end
        end
        unless thermal_zone.zoneControlHumidistat.empty?
          humidistat = thermal_zone.zoneControlHumidistat.get
          unless humidistat.humidifyingRelativeHumiditySetpointSchedule.empty?
            humidifying_schedule = humidistat.humidifyingRelativeHumiditySetpointSchedule.get
            hash[:setpoint][:humidifying_schedule] = humidifying_schedule.nameString
          end
          unless humidistat.dehumidifyingRelativeHumiditySetpointSchedule.empty?
            dehumidifying_schedule = humidistat.dehumidifyingRelativeHumiditySetpointSchedule.get
            hash[:setpoint][:dehumidifying_schedule] = dehumidifying_schedule.nameString
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

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
    class ScheduleRuleset < ModelObject
      attr_reader :errors, :warnings
            
      def initialize(hash = {})
        super(hash)
      end

      def defaults
        result = {}
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        object = openstudio_model.getScheduleRulesetByName(@hash[:name])
        return object.get if object.is_initialized
        nil
      end


      def create_openstudio_object(openstudio_model)
        openstudio_schedule_ruleset = OpenStudio::Model::ScheduleRuleset.new(openstudio_model)
        openstudio_schedule_ruleset.setName(@hash[:name])
        schedule_type_limits = OpenStudio::Model::ScheduleTypeLimits.new(openstudio_model)
        schedule_type_limits.setUnitType(@hash[:schedule_type_limits][:unit_type])
        schedule_type_limits.setLowerLimitValue(@hash[:schedule_type_limits][:lower_limit_value])
        schedule_type_limits.setUpperLimitValue(@hash[:schedule_type_limits][:upper_limit_value])
        case 
        when @hash[:schedule_type_limits][:numeric_type][:type] == 'ScheduleContinuous'
          schedule_type_limits.setNumericType('Continuous')
        when @hash[:schedule_type_limits][:numeric_type][:type] == 'ScheduleDiscrete'
          schedule_type_limits.setNumericType('Discrete')
        end
        openstudio_summer_day = OpenStudio::Model::ScheduleDay.new(openstudio_model)
        openstudio_schedule_ruleset.setSummerDesignDaySchedule(openstudio_summer_day)
        openstudio_schedule_ruleset.summerDesignDaySchedule.setName(@hash[:summer_designday_schedule][:name])
        if @hash[:summer_designday_schedule][:interpolate_to_timestep]
          openstudio_schedule_ruleset.summerDesignDaySchedule.setInterpolatetoTimestep(@hash[:summer_designday_schedule][:interpolate_to_timestep])
        else 
          openstudio_schedule_ruleset.summerDesignDaySchedule.setInterpolatetoTimestep(@@schema[:definitions][:ScheduleDay][:properties][:interpolate_to_timestep][:default])
        end
        @hash[:summer_designday_schedule][:day_values].each do |day_values|
          openstudio_schedule_ruleset.summerDesignDaySchedule.addValue(OpenStudio::Time.new(0, day_values[:time][:hour], day_values[:time][:minute],0),day_values[:value_until_time])
        end
        openstudio_winter_day = OpenStudio::Model::ScheduleDay.new(openstudio_model)
        openstudio_schedule_ruleset.setWinterDesignDaySchedule(openstudio_winter_day)
        openstudio_schedule_ruleset.winterDesignDaySchedule.setName(@hash[:winter_designday_schedule][:name])
        if @hash[:winter_designday_schedule][:interpolate_to_timestep]
          openstudio_schedule_ruleset.winterDesignDaySchedule.setInterpolatetoTimestep(@hash[:winter_designday_schedule][:interpolate_to_timestep])
        else
          openstudio_schedule_ruleset.winterDesignDaySchedule.setInterpolatetoTimestep(@@schema[:definitions][:ScheduleDay][:properties][:interpolate_to_timestep][:default])
        end
        @hash[:winter_designday_schedule][:day_values].each do |day_values|
          openstudio_schedule_ruleset.winterDesignDaySchedule.addValue(OpenStudio::Time.new(0, day_values[:time][:hour], day_values[:time][:minute],0), day_values[:value_until_time])
        end
        openstudio_default_day = OpenStudio::Model::ScheduleDay.new(openstudio_model)
        openstudio_schedule_ruleset.defaultDaySchedule.setName(@hash[:default_day_schedule][:name])
        if @hash[:default_day_schedule][:interpolate_to_timestep]
          openstudio_schedule_ruleset.defaultDaySchedule.setInterpolatetoTimestep(@hash[:default_day_schedule][:interpolate_to_timestep])
        else
          openstudio_schedule_ruleset.defaultDaySchedule.setInterpolatetoTimestep(@@schema[:definitions][:ScheduleDay][:properties][:interpolate_to_timestep][:default])
        end
        @hash[:default_day_schedule][:day_values].each do |day_values|
          openstudio_schedule_ruleset.defaultDaySchedule.addValue(OpenStudio::Time.new(0, day_values[:time][:hour], day_values[:time][:minute],0), day_values[:value_until_time])
        end
        @hash[:schedule_rules].each do |schedule_rule|
          openstudio_schedule_day_rule = OpenStudio::Model::ScheduleDay.new(openstudio_model)
          openstudio_schedule_rule = OpenStudio::Model::ScheduleRule.new(openstudio_schedule_ruleset, openstudio_schedule_day_rule)
          openstudio_schedule_rule.daySchedule.setName(schedule_rule[:schedule_day][:name])
          if schedule_rule[:schedule_day][:interpolate_to_timestep]
            openstudio_schedule_rule.daySchedule.setInterpolatetoTimestep(schedule_rule[:schedule_day][:interpolate_to_timestep])
          else
            openstudio_schedule_rule.daySchedule.setInterpolatetoTimestep(@@schema[:definitions][:ScheduleDay][:properties][:interpolate_to_timestep][:default])
          end
          schedule_rule[:schedule_day][:day_values].each do |day_values|
            openstudio_schedule_rule.daySchedule.addValue(OpenStudio::Time.new(0,day_values[:time][:hour], day_values[:time][:minute],0), day_values[:value_until_time])
          end
          openstudio_start_date = openstudio_schedule_rule.setStartDate(OpenStudio::Date.new(OpenStudio::MonthOfYear.new(schedule_rule[:start_period][:date][:month]), schedule_rule[:start_period][:date][:day]))
          #setStartTime?
          openstudio_end_date = openstudio_schedule_rule.setEndDate(OpenStudio::Date.new(OpenStudio::MonthOfYear.new(schedule_rule[:end_period][:date][:month]), schedule_rule[:end_period][:date][:day]))
          #setEndTime?
          openstudio_schedule_ruleset_name = openstudio_schedule_rule.setName(schedule_rule[:name])
          openstudio_schedule_ruleset_name = openstudio_schedule_rule.setApplySunday(schedule_rule[:apply_sunday])
          openstudio_schedule_ruleset_name = openstudio_schedule_rule.setApplyMonday(schedule_rule[:apply_monday])
          openstudio_schedule_ruleset_name = openstudio_schedule_rule.setApplyTuesday(schedule_rule[:apply_tuesday])
          openstudio_schedule_ruleset_name = openstudio_schedule_rule.setApplyWednesday(schedule_rule[:apply_wednesday])
          openstudio_schedule_ruleset_name = openstudio_schedule_rule.setApplyThursday(schedule_rule[:apply_thursday])
          openstudio_schedule_ruleset_name = openstudio_schedule_rule.setApplyFriday(schedule_rule[:apply_friday])
          openstudio_schedule_ruleset_name = openstudio_schedule_rule.setApplySaturday(schedule_rule[:apply_saturday])
        end
        openstudio_schedule_ruleset
      end

    end #ScheduleRuleset
  end #EnergyModel
end #Ladybug

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

require 'honeybee/schedule/ruleset'
require 'from_openstudio/model_object'

module Honeybee
  class ScheduleRulesetAbridged < ModelObject

    def self.from_schedule_ruleset(schedule_ruleset)
      # create an empty hash
      hash = {}
      hash[:type] = 'ScheduleRulesetAbridged'
      # set the primary (required) day schedules of the object
      hash[:identifier] = clean_name(schedule_ruleset.nameString)
      unless schedule_ruleset.displayName.empty?
        hash[:display_name] = (schedule_ruleset.displayName.get).force_encoding("UTF-8")
      end
      hash[:default_day_schedule] = clean_name(schedule_ruleset.defaultDaySchedule.nameString)
      hash[:summer_designday_schedule] = clean_name(schedule_ruleset.summerDesignDaySchedule.nameString)
      hash[:winter_designday_schedule] = clean_name(schedule_ruleset.winterDesignDaySchedule.nameString)
      hash[:holiday_schedule] = clean_name(schedule_ruleset.holidaySchedule.nameString)

      # create a list of all day schedules referenced in the Ruleset
      schedule_days, day_ids = [], []
      required_days = [
        schedule_ruleset.defaultDaySchedule,
        schedule_ruleset.summerDesignDaySchedule,
        schedule_ruleset.winterDesignDaySchedule,
        schedule_ruleset.holidaySchedule
      ]
      required_days.each do |day_sch|
        unless day_ids.include? day_sch.nameString
          schedule_days << day_sch
          day_ids << day_sch.nameString
        end
      end

      # loop through the rules and add them along with their day schedules
      hash[:schedule_rules] = []
      schedule_ruleset.scheduleRules.each do |schedule_rule|
        hash[:schedule_rules] << ScheduleRulesetAbridged.from_schedule_rule(schedule_rule)
        day_sch = schedule_rule.daySchedule
        unless day_ids.include? day_sch.nameString
          schedule_days << day_sch
          day_ids << day_sch.nameString
        end
      end

      # write all of the day schedule specifications into the hash
      hash[:day_schedules] = []
      schedule_days.each do |schedule_day|
        hash[:day_schedules] << ScheduleRulesetAbridged.from_day_schedule(schedule_day)
      end

      # assing any schedule type limits if they exist
      unless schedule_ruleset.scheduleTypeLimits.empty?
        typ_lim = schedule_ruleset.scheduleTypeLimits.get
        hash[:schedule_type_limit] = clean_name(typ_lim.nameString)
      end

      hash
    end

    def self.from_day_schedule(day_schedule)
      hash = {}
      hash[:type] = 'ScheduleDay'
      hash[:identifier] = clean_name(day_schedule.nameString)
      hash[:interpolate] = day_schedule.interpolatetoTimestep
      hash[:values] = day_schedule.values
      time_until = [[0,0]]
      day_schedule.times.each do |time|
        time_until << [time.hours, time.minutes]
      end
      time_until.delete_at(-1)
      hash[:times] = time_until

      hash
    end

    def self.from_schedule_rule(schedule_rule)
      hash = {}
      hash[:type] = 'ScheduleRuleAbridged'
      hash[:schedule_day] = clean_name(schedule_rule.daySchedule.nameString)
      hash[:apply_sunday] = schedule_rule.applySunday
      hash[:apply_monday] = schedule_rule.applyMonday
      hash[:apply_tuesday] = schedule_rule.applyTuesday
      hash[:apply_wednesday] = schedule_rule.applyWednesday
      hash[:apply_thursday] = schedule_rule.applyThursday
      hash[:apply_friday] = schedule_rule.applyFriday
      hash[:apply_saturday] = schedule_rule.applySaturday
      
      #boost optional
      unless schedule_rule.startDate.empty?
        start_date = schedule_rule.startDate.get       
        hash[:start_date] = [(start_date.monthOfYear).value, start_date.dayOfMonth]
        if start_date.isLeapYear
          hash[:start_date] << 1
        end
      end

      #boost optional
      unless schedule_rule.endDate.empty?
        end_date = schedule_rule.endDate.get
        hash[:end_date] = [(end_date.monthOfYear).value, end_date.dayOfMonth]
        if start_date.isLeapYear
          hash[:end_date] << 1
        end
      end

      hash
    end

  end # ScheduleRulesetAbridged
end # Honeybee

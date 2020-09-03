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

require 'from_honeybee/model_object'

require 'openstudio'

module FromHoneybee
  class ScheduleRulesetAbridged < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)

      raise "Incorrect model type '#{@type}'" unless @type == 'ScheduleRulesetAbridged'
    end

    def defaults
      @@schema[:components][:schemas][:ScheduleRulesetAbridged][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getScheduleRulesetByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create openstudio schedule ruleset object
      os_sch_ruleset = OpenStudio::Model::ScheduleRuleset.new(openstudio_model)
      os_sch_ruleset.setName(@hash[:identifier])

      # assign schedule type limit
      sch_type_limit_obj = nil
      if @hash[:schedule_type_limit]
        schedule_type_limit = openstudio_model.getScheduleTypeLimitsByName(@hash[:schedule_type_limit])
        unless schedule_type_limit.empty?
          sch_type_limit_obj = schedule_type_limit.get
          os_sch_ruleset.setScheduleTypeLimits(sch_type_limit_obj)
        end
      end

      # loop through day schedules and create openstudio schedule day object
      @hash[:day_schedules].each do |day_schedule|
        day_schedule_new = OpenStudio::Model::ScheduleDay.new(openstudio_model)
        day_schedule_new.setName(day_schedule[:identifier])
        unless sch_type_limit_obj.nil?
          day_schedule_new.setScheduleTypeLimits(sch_type_limit_obj)
        end
        values_day_new = day_schedule[:values]
        times_day_new = day_schedule[:times]
        times_day_new.delete_at(0)  # Remove [0, 0] from array at index 0.
        times_day_new.push([24, 0])  # Add [24, 0] at index 0
        values_day_new.each_index do |i|
          time_until = OpenStudio::Time.new(0, times_day_new[i][0], times_day_new[i][1], 0)
          day_schedule_new.addValue(time_until, values_day_new[i])
        end
      end

      # assign holiday schedule      
      if @hash[:holiday_schedule]      
        holiday_schedule = openstudio_model.getScheduleDayByName(@hash[:holiday_schedule])
        unless holiday_schedule.empty?
          holiday_schedule_object = holiday_schedule.get
          begin
            os_sch_ruleset.setHolidaySchedule(holiday_schedule_object)
          rescue NoMethodError  # REMOVE: Once the upgrade to OpenStudio 3.0 is official
          end
        end
      end

      # assign summer design day schedule 
      if @hash[:summer_designday_schedule]
        summer_design_day = openstudio_model.getScheduleDayByName(@hash[:summer_designday_schedule])
        unless summer_design_day.empty?
          summer_design_day_object = summer_design_day.get
          os_sch_ruleset.setSummerDesignDaySchedule(summer_design_day_object)
        end
      end

      # assign winter design day schedule
      if @hash[:winter_designday_schedule]
        winter_design_day = openstudio_model.getScheduleDayByName(@hash[:winter_designday_schedule])
        unless winter_design_day.empty?
          winter_design_day_object = winter_design_day.get
          os_sch_ruleset.setWinterDesignDaySchedule(winter_design_day_object)
        end
      end       
    
      # assign default day schedule
      default_day_schedule = openstudio_model.getScheduleDayByName(@hash[:default_day_schedule])
      unless default_day_schedule.empty?
        default_day_schedule_object = default_day_schedule.get
        values = default_day_schedule_object.values
        times = default_day_schedule_object.times
        values.each_index do |i|
          os_sch_ruleset.defaultDaySchedule.addValue(times[i], values[i])
        end
      end

      # assign schedule rules
      if @hash[:schedule_rules]
        @hash[:schedule_rules].each do |rule|          
          openstudio_schedule_rule = OpenStudio::Model::ScheduleRule.new(os_sch_ruleset)
          openstudio_schedule_rule.setApplySunday(rule[:apply_sunday])
          openstudio_schedule_rule.setApplyMonday(rule[:apply_monday])
          openstudio_schedule_rule.setApplyTuesday(rule[:apply_tuesday])
          openstudio_schedule_rule.setApplyWednesday(rule[:apply_wednesday])
          openstudio_schedule_rule.setApplyThursday(rule[:apply_thursday])
          openstudio_schedule_rule.setApplyFriday(rule[:apply_friday])
          openstudio_schedule_rule.setApplySaturday(rule[:apply_saturday])
          year_description = openstudio_model.getYearDescription
          start_date = year_description.makeDate(rule[:start_date][0], rule[:start_date][1])
          end_date = year_description.makeDate(rule[:end_date][0], rule[:end_date][1])
          openstudio_schedule_rule.setStartDate(start_date)
          openstudio_schedule_rule.setEndDate(end_date)

          schedule_rule_day = openstudio_model.getScheduleDayByName(rule[:schedule_day])
          unless schedule_rule_day.empty?
            schedule_rule_day_object = schedule_rule_day.get

            values_day = schedule_rule_day_object.values
            times_day = schedule_rule_day_object.times

            values_day.each_index do |i|
              openstudio_schedule_rule.daySchedule.addValue(times_day[i], values_day[i])
            end
          end

          #set schedule rule index
          index = @hash[:schedule_rules].find_index(rule)
          os_sch_ruleset.setScheduleRuleIndex(openstudio_schedule_rule, index)
        end
      end

      os_sch_ruleset
    end

  end #ScheduleRulesetAbridged
end #FromHoneybee

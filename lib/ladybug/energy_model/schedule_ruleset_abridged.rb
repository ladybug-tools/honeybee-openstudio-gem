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

require 'openstudio'

module Ladybug
  module EnergyModel
    class ScheduleRulesetAbridged < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'ScheduleRulesetAbridged'
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

        @hash[:day_schedules].each do |day_schedule|
          day_schedule_new = OpenStudio::Model::ScheduleDay.new(openstudio_model)
          day_schedule_new.setName(day_schedule[:name])
          values_day_new = day_schedule[:values]
          times_day_new = day_schedule[:times]
          #Remove [0,0] from array at index 0.
          times_day_new.delete_at(0)
          #Add [24,1] at index 0
          times_day_new.unshift([24,1])
          values_day_new.each_index do |i|
            list = Array(0..i-1)
            list.push(-1)
            list.each_with_index do |item, index|
              day_schedule_new.addValue((OpenStudio::Time.new(0,times_day_new[item+1][0],times_day_new[item+1][1], 0)-(OpenStudio::Time.new(0,0,1,0))), values_day_new[index])
            end
          end
        end
       
        if @hash[:summer_designday_schedule]
          summer_design_day = openstudio_model.getScheduleDayByName(@hash[:summer_designday_schedule])
          unless summer_design_day.empty?
            summer_design_day_object = summer_design_day.get
            openstudio_schedule_ruleset.setSummerDesignDaySchedule(summer_design_day_object)
          end
        end

        if @hash[:winter_designday_schedule]
          winter_design_day = openstudio_model.getScheduleDayByName(@hash[:winter_designday_schedule])
          unless winter_design_day.empty?
            winter_design_day_object = winter_design_day.get
            openstudio_schedule_ruleset.setWinterDesignDaySchedule(winter_design_day_object)
          end
        end       
     
        default_day_schedule = openstudio_model.getScheduleDayByName(@hash[:default_day_schedule])
        unless default_day_schedule.empty?
          default_day_schedule_object = default_day_schedule.get
          values = default_day_schedule_object.values
          times = default_day_schedule_object.times
          values.each_index do |i|
            openstudio_schedule_ruleset.defaultDaySchedule.addValue(times[i], values[i])
          end
        end
        
        if @hash[:schedule_type_limit]
          schedule_type_limit = openstudio_model.getScheduleTypeLimitsByName(@hash[:schedule_type_limit])
          unless schedule_type_limit.empty?
            schedule_type_limit_object = schedule_type_limit.get
            openstudio_schedule_ruleset.setScheduleTypeLimits(schedule_type_limit_object)
          end
        end

        if @hash[:schedule_rules]
          @hash[:schedule_rules].each do |rule|          
            openstudio_schedule_rule = OpenStudio::Model::ScheduleRule.new(openstudio_schedule_ruleset)
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
            openstudio_schedule_ruleset.setScheduleRuleIndex(openstudio_schedule_rule, index)
          end
        end

        openstudio_schedule_ruleset
      end

    end #ScheduleRulesetAbridged
  end #EnergyModel
end #Ladybug

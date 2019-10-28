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
        
        if @hash[:summer_designday_schedule]
          summer_designday_schedule = OpenStudio::Model::ScheduleDay.new(openstudio_model)
          values = @hash[:summer_designday_schedule][:values]
          times = @hash[:summer_designday_schedule][:times]
          values.each_index do |i|
            summer_designday_schedule.addValue(OpenStudio::Time.new(0,times[i][0],times[i][1] ,0), values[i])
          end 
        end

        openstudio_schedule_ruleset.setSummerDesignDaySchedule(summer_designday_schedule)

        if @hash[:winter_designday_schedule]
          winter_designday_schedule = OpenStudio::Model::ScheduleDay.new(openstudio_model)
          values = @hash[:winter_designday_schedule][:values]
          times = @hash[:winter_designday_schedule][:times]
          values.each_index do |i|
            winter_designday_schedule.addValue(OpenStudio::Time.new(0,times[i][0],times[i][1] ,0), values[i])
          end 
        end

        openstudio_schedule_ruleset.setWinterDesignDaySchedule(winter_designday_schedule)
        
     
        values_default_day = @hash[:default_day_schedule][:values]
        times_default_day = @hash[:default_day_schedule][:times]

        values_default_day.each_index do |i|
          openstudio_schedule_ruleset.defaultDaySchedule.addValue(OpenStudio::Time.new(0,times_default_day[i][0],times_default_day[i][1] ,0), values_default_day[i])
        end 

        if @hash[:schedule_type_limit]
          
          schedule_type_limit_object = nil
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

            values_day = rule[:schedule_day][:values]
            times_day = rule[:schedule_day][:times]

            values_day.each_index do |i|
              openstudio_schedule_rule.daySchedule.addValue(OpenStudio::Time.new(0,times_day[i][0], times_day[i][1], 0), values_day[i])
            end

          end
        end
      end
      

    end #ScheduleRulesetAbridged
  end #EnergyModel
end #Ladybug

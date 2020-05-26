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

require 'from_honeybee/extension'
require 'from_honeybee/model_object'

module FromHoneybee
  class ScheduleFixedIntervalAbridged < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)

      raise "Incorrect model type '#{@type}'" unless @type == 'ScheduleFixedIntervalAbridged'
    end

    def defaults
      @@schema[:components][:schemas][:ScheduleFixedIntervalAbridged][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      model_schedule = openstudio_model.getScheduleFixedIntervalByName(@hash[:identifier])
      return model_schedule.get unless model_schedule.empty?
      nil
    end
  
    def to_openstudio(openstudio_model)
      # create the new schedule
      os_fi_schedule = OpenStudio::Model::ScheduleFixedInterval.new(openstudio_model)
      os_fi_schedule.setName(@hash[:identifier])

      # assign start date
      if @hash[:start_date]
        os_fi_schedule.setStartMonth(@hash[:start_date][0])
        os_fi_schedule.setStartDay(@hash[:start_date][1])
      else
        os_fi_schedule.setStartMonth(defaults[:start_date][:default][0])
        os_fi_schedule.setStartDay(defaults[:start_date][:default][1])
      end

      # assign the interpolate value
      unless @hash[:interpolate].nil?
        os_fi_schedule.setInterpolatetoTimestep(@hash[:interpolate])
      else
        os_fi_schedule.setInterpolatetoTimestep(defaults[:interpolate][:default])
      end

      # assign the schedule type limit
      if @hash[:schedule_type_limit]
        schedule_type_limit = openstudio_model.getScheduleTypeLimitsByName(@hash[:schedule_type_limit])
        unless schedule_type_limit.empty?
          schedule_type_limit_object = schedule_type_limit.get
          os_fi_schedule.setScheduleTypeLimits(schedule_type_limit_object)
        end
      end

      # assign the timestep
      if @hash[:timestep]
        timestep = @hash[:timestep]
        interval_length = 60 / timestep
        os_fi_schedule.setIntervalLength(interval_length)
      else
        timestep = defaults[:timestep][:default]
        interval_length = 60 / timestep
        os_fi_schedule.setIntervalLength(interval_length)
      end
      openstudio_interval_length = OpenStudio::Time.new(0, 0, interval_length) 

      # assign the values as a timeseries
      year_description = openstudio_model.getYearDescription

      # set is leap year = true in case start date has 3 integers
      if @hash[:start_date][2] 
        year_description.setIsLeapYear(true)
      end

      start_date = year_description.makeDate(@hash[:start_date][0], @hash[:start_date][1])

      values = @hash[:values]
      timeseries = OpenStudio::TimeSeries.new(start_date, openstudio_interval_length, OpenStudio.createVector(values), '')
      os_fi_schedule.setTimeSeries(timeseries)

      os_fi_schedule
    end
    
  end #ScheduleFixedIntervalAbridged
end #FromHoneybee

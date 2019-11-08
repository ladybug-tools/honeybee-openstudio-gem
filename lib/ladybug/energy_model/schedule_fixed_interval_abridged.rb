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

require 'ladybug/energy_model/extension'
require 'ladybug/energy_model/model_object'

module Ladybug
  module EnergyModel
    class ScheduleFixedIntervalAbridged < ModelObject
      attr_reader :errors, :warnings

      def initialize(hash = {})
        super(hash)

        raise "Incorrect model type '#{@type}'" unless @type == 'ScheduleFixedIntervalAbridged'
      end

      def defaults
        result = {}
        result
      end

      def find_existing_openstudio_object(openstudio_model)
        model_schedule = openstudio_model.getScheduleFixedIntervalByName(@hash[:name])
        return model_schedule.get unless model_schedule.empty?
        nil
      end
    
      def create_openstudio_object(openstudio_model)    
        openstudio_schedule_fixed_interval = OpenStudio::Model::ScheduleFixedInterval.new(openstudio_model)
        openstudio_schedule_fixed_interval.setName(@hash[:name])
        openstudio_schedule_fixed_interval.setStartMonth(@hash[:start_date][:month])
        openstudio_schedule_fixed_interval.setStartDay(@hash[:start_date][:day])
        if @hash[:interpolate]
          openstudio_schedule_fixed_interval.setInterpolatetoTimestep(@hash[:interpolate])
        else
          openstudio_schedule_fixed_interval.setInterpolatetoTimestep(@@schema[:definitions][:ScheduleFixedIntervalAbridged][:properties][:interpolate][:default])
        end
        
        if @hash[:schedule_type_limit]
          schedule_type_limit = openstudio_model.getScheduleTypeLimitsByName(@hash[:schedule_type_limit])
          unless schedule_type_limit.empty?
            schedule_type_limit_object = schedule_type_limit.get
            openstudio_schedule_fixed_interval.setScheduleTypeLimits(schedule_type_limit_object)
          end
        end
        
        if @hash[:timestep]
          timestep = @hash[:timestep]
          interval_length = 60/timestep
          openstudio_schedule_fixed_interval.setIntervalLength(60/timestep)
        else
          timestep = @@schema[:definitions][:ScheduleFixedIntervalAbridged][:properties][:timestep][:default]
          interval_length = 60/timestep
          openstudio_schedule_fixed_interval.setIntervalLength(60/timestep)
        end
        openstudio_interval_length = OpenStudio::Time.new(0,0,interval_length) 

        year_description = openstudio_model.getYearDescription
        start_date = year_description.makeDate(@hash[:start_date][:month], @hash[:start_date][:day])
        values = @hash[:values]
        timeseries = OpenStudio::TimeSeries.new(start_date, openstudio_interval_length, OpenStudio.createVector(values), '') 
        openstudio_schedule_fixed_interval.setTimeSeries(timeseries)

        openstudio_schedule_fixed_interval
      end
      
    end #ScheduleFixedIntervalAbridged
  end #EnergyModel
end #Ladybug

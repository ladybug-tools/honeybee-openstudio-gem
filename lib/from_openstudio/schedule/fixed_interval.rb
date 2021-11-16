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

require 'honeybee/schedule/fixed_interval'
require 'from_openstudio/model_object'

module Honeybee
    class ScheduleFixedIntervalAbridged < ModelObject

        def self.from_schedule_fixedinterval(schedule_fixedinterval, is_leap_year)
            # create an empty hash
            hash = {}
            hash[:type] = 'ScheduleFixedIntervalAbridged'
            hash[:identifier] = clean_name(schedule_fixedinterval.nameString)
            unless schedule_fixedinterval.displayName.empty?
                hash[:display_name] = (schedule_fixedinterval.displayName.get).force_encoding("UTF-8")
            end
            start_month = schedule_fixedinterval.startMonth
            start_day = schedule_fixedinterval.startDay
            if is_leap_year
                # if it is a leap year then add  1 as third value
                hash[:start_date] = [start_month, start_day, 1]
            else
                hash[:start_date] = [start_month, start_day]
            end
            hash[:interpolate] = schedule_fixedinterval.interpolatetoTimestep
            # assigning schedule type limit if it exists
            unless schedule_fixedinterval.scheduleTypeLimits.empty?
                typ_lim = schedule_fixedinterval.scheduleTypeLimits.get
                hash[:schedule_type_limit] = clean_name(typ_lim.nameString)
            end
            interval_length = schedule_fixedinterval.intervalLength
            hash[:timestep] = 60 / interval_length.to_i
            # get values from schedule fixed interval
            values = schedule_fixedinterval.timeSeries.values
            value_array = []
            for i in 0..(values.size - 1)
                value_array << values[i]
            end
            hash[:values] = value_array

            hash
        end
    
    end
end

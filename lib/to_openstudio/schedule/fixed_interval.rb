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

require 'to_openstudio/model_object'

module Honeybee
  class ScheduleFixedIntervalAbridged

    def find_existing_openstudio_object(openstudio_model)
      model_schedule = openstudio_model.getScheduleFixedIntervalByName(@hash[:identifier])
      return model_schedule.get unless model_schedule.empty?
      nil
    end

    def to_openstudio(openstudio_model, schedule_csv_dir = nil, include_datetimes = nil, schedule_csvs = nil)
      if schedule_csv_dir
        to_schedule_file(openstudio_model, schedule_csv_dir, include_datetimes, schedule_csvs)
      else
        to_schedule_fixed_interval(openstudio_model)
      end
    end

    def start_month
      if @hash[:start_date]
        return @hash[:start_date][0]
      end
      defaults[:start_date][:default][0]
    end

    def start_day
      if @hash[:start_date]
        return @hash[:start_date][1]
      end
      defaults[:start_date][:default][1]
    end

    def interpolate
      if @hash[:interpolate]
        return @hash[:interpolate]
      end
      defaults[:interpolate][:default]
    end

    def timestep
      if @hash[:timestep]
        return @hash[:timestep]
      end
      defaults[:timestep][:default]
    end

    def placeholder_value
      if @hash[:placeholder_value]
        return @hash[:placeholder_value]
      end
      defaults[:placeholder_value][:default]
    end

    def to_schedule_fixed_interval(openstudio_model)
      # create the new schedule
      os_fi_schedule = OpenStudio::Model::ScheduleFixedInterval.new(openstudio_model)
      os_fi_schedule.setName(@hash[:identifier])

      # assign start date
      os_fi_schedule.setStartMonth(start_month)
      os_fi_schedule.setStartDay(start_day)

      # assign the interpolate value
      os_fi_schedule.setInterpolatetoTimestep(interpolate)

      # assign the schedule type limit
      if @hash[:schedule_type_limit]
        schedule_type_limit = openstudio_model.getScheduleTypeLimitsByName(@hash[:schedule_type_limit])
        unless schedule_type_limit.empty?
          schedule_type_limit_object = schedule_type_limit.get
          os_fi_schedule.setScheduleTypeLimits(schedule_type_limit_object)
        end
      end

      # assign the timestep
      interval_length = 60 / timestep
      os_fi_schedule.setIntervalLength(interval_length)
      openstudio_interval_length = OpenStudio::Time.new(0, 0, interval_length)

      # assign the values as a timeseries
      year_description = openstudio_model.getYearDescription
      start_date = year_description.makeDate(start_month, start_day)
      timeseries = OpenStudio::TimeSeries.new(start_date, openstudio_interval_length, OpenStudio.createVector(@hash[:values]), '')
      os_fi_schedule.setTimeSeries(timeseries)

      os_fi_schedule
    end

    def to_schedule_file(openstudio_model, schedule_csv_dir, include_datetimes, schedule_csvs)

      # in order to combine schedules in the same csv file they must have the same key
      schedule_key = "#{@hash[:identifier]}_#{start_month}_#{start_day}_#{timestep}"

      # get start and end date times
      yd = openstudio_model.getYearDescription
      date_time = OpenStudio::DateTime.new(yd.makeDate(1, 1), OpenStudio::Time.new(0,0,0))
      start_date_time = OpenStudio::DateTime.new(yd.makeDate(start_month, start_day), OpenStudio::Time.new(0,0,0))
      end_date_time = OpenStudio::DateTime.new(yd.makeDate(12, 31), OpenStudio::Time.new(1,0,0))

      # get timestep
      interval_length = 60 / timestep
      dt = OpenStudio::Time.new(0, 0, interval_length, 0)

      # get values and date times
      values = @hash[:values]
      num_values = values.size
      i_values = 0
      padded_values = []
      date_times = []
      pv = placeholder_value

      while date_time < end_date_time
        date = date_time.date
        time = date_time.time
        date_times << "#{date.dayOfMonth} #{date.monthOfYear.valueName} #{time.hours.to_s.rjust(2,'0')}:#{time.minutes.to_s.rjust(2,'0')}"

        if date_time < start_date_time
          padded_values << pv
        elsif i_values < num_values
          padded_values << values[i_values]
          i_values += 1
        else
          padded_values << pv
        end

        date_time += dt
      end


      # find or create the schedule csv object which will hold the filename and columns
      filename = nil
      columns = nil
      os_external_file = nil
      schedule_csv = schedule_csvs[schedule_key]
      if schedule_csv.nil?
        # file name to write
        filename = "#{@hash[:identifier]}.csv".gsub(' ', '_')

        # columns of data
        columns = []
        if include_datetimes
          columns << ['Date Times'].concat(date_times)
        end

        # schedule csv file must exist even though it has no content yet
        path = File.join(schedule_csv_dir, filename)
        if !File.exist?(path)
          File.open(path, 'w') {|f| f.puts ''}
        end

        # get the external file which points to the schedule csv file
        os_external_file = OpenStudio::Model::ExternalFile.getExternalFile(openstudio_model, filename)
        os_external_file = os_external_file.get

        schedule_csv = {filename: filename, columns: columns, os_external_file: os_external_file}
        schedule_csvs[schedule_key] = schedule_csv
      else
        filename = schedule_csv[:filename]
        columns = schedule_csv[:columns]
        os_external_file = schedule_csv[:os_external_file]
      end

      # insert the padded_values to write later
      columns << [@hash[:identifier]].concat(padded_values)

      # create the schedule file
      column = columns.size # 1 based index
      rowsToSkip = 1
      os_schedule_file = OpenStudio::Model::ScheduleFile.new(os_external_file, column, rowsToSkip)
      os_schedule_file.setName(@hash[:identifier])
      os_schedule_file.setInterpolatetoTimestep(interpolate)
      os_schedule_file.setMinutesperItem(interval_length)

      # assign the schedule type limit
      if @hash[:schedule_type_limit]
        schedule_type_limit = openstudio_model.getScheduleTypeLimitsByName(@hash[:schedule_type_limit])
        unless schedule_type_limit.empty?
          schedule_type_limit_object = schedule_type_limit.get
          os_schedule_file.setScheduleTypeLimits(schedule_type_limit_object)
        end
      end

      os_schedule_file
    end

  end #ScheduleFixedIntervalAbridged
end #Honeybee

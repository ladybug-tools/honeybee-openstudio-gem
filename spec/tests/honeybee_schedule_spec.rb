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

require_relative '../spec_helper'

RSpec.describe Honeybee do
  it 'can load schedule fixed interval 1' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    file = File.join(File.dirname(__FILE__), '../samples/schedule/schedule_fixedinterval_increasing_fine_timestep.json')
    honeybee_obj_1 = Honeybee::ScheduleFixedIntervalAbridged.read_from_disk(file)

    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    expect(object1.nameString).to eq 'Solstice Increasing'
    #expect((object1.additionalProperties.featureNames)).to include ("DisplayName")
    expect((object1.displayName.get)).to eq 'Solstice Increasing%'

    start_day = object1.startDay
    expect(start_day).to eq(1)

    interpolate = object1.interpolatetoTimestep
    expect(interpolate).to eq(false)

    interval_length = object1.intervalLength
    expect(interval_length).to eq(10.0)
  end

  it 'can load schedule fixed interval 2' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    file = File.join(File.dirname(__FILE__), '../samples/schedule/schedule_fixedinterval_increasing_single_day.json')
    honeybee_obj_1 = Honeybee::ScheduleFixedIntervalAbridged.read_from_disk(file)

    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load schedule fixed interval 3' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2016)
    year_description = openstudio_model.getYearDescription
    year_description.setIsLeapYear(true)

    file = File.join(File.dirname(__FILE__), '../samples/schedule/schedule_fixedinterval_leap_year.json')
    honeybee_obj_1 = Honeybee::ScheduleFixedIntervalAbridged.read_from_disk(file)

    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load schedule fixed interval 4' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    file = File.join(File.dirname(__FILE__), '../samples/schedule/schedule_fixedinterval_random_annual.json')
    honeybee_obj_1 = Honeybee::ScheduleFixedIntervalAbridged.read_from_disk(file)

    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load schedule primary school occupancy' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)

    file = File.join(File.dirname(__FILE__), '../samples/schedule/schedule_primary_school_occupancy.json')
    honeybee_obj_1 = Honeybee::ScheduleRulesetAbridged.read_from_disk(file)

    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    schedule_rules = object1.scheduleRules
    expect(schedule_rules).not_to be nil
    start_date = schedule_rules[0].startDate
    expect(start_date).not_to be nil
    app_mon = schedule_rules[0].applyMonday
    expect(app_mon).to eq(true)

    day_schedule = schedule_rules[0].daySchedule
    expect(day_schedule).not_to be nil
    time = day_schedule.times
    expect(time).not_to be nil
    expect(time.size).to eq(3)
    value = day_schedule.values
    expect(value).not_to be nil

    default_day = object1.defaultDaySchedule
    expect(default_day).not_to be nil
    summer_design = object1.summerDesignDaySchedule
    expect(summer_design.nameString).to eq 'School Summer Design 1'
    expect(summer_design).not_to be nil
    schedule_type = object1.scheduleTypeLimits
    expect(schedule_type).not_to be nil

  end

  it 'can load schedule ruleset office occupancy' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    file = File.join(File.dirname(__FILE__), '../samples/schedule/schedule_ruleset_office_occupancy.json')
    honeybee_obj_1 = Honeybee::ScheduleRulesetAbridged.read_from_disk(file)

    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load schedule ruleset simple repeating' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    file = File.join(File.dirname(__FILE__), '../samples/schedule/schedule_ruleset_simple_repeating.json')
    honeybee_obj_1 = Honeybee::ScheduleRulesetAbridged.read_from_disk(file)

    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load schedule type limit' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    file = File.join(File.dirname(__FILE__), '../samples/schedule/scheduletypelimit_temperature.json')
    honeybee_obj_1 = Honeybee::ScheduleTypeLimit.read_from_disk(file)

    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can export a schedule csv starting mid year' do
    schedule_dir = File.join(File.dirname(__FILE__), '..', 'output', 'schedule_osms')
    schedule_file_dir = File.join(schedule_dir, 'schedule_fixedinterval_increasing_fine_timestep')

    # translate to schedule file
    if File.directory?(schedule_file_dir)
      FileUtils.rm_rf(schedule_file_dir)
    end
    FileUtils.mkdir_p(schedule_file_dir)

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    workflow = openstudio_model.workflowJSON
    workflow.addFilePath(schedule_file_dir)
    openstudio_model.setWorkflowJSON(workflow)

    schedule_csvs = {}

    file = File.join(File.dirname(__FILE__), '../samples/schedule/schedule_fixedinterval_increasing_fine_timestep.json')
    honeybee_obj_1 = Honeybee::ScheduleFixedIntervalAbridged.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio(openstudio_model, schedule_file_dir, true, schedule_csvs)
    expect(object1).not_to be nil

    externalFile = object1.externalFile
    expect(externalFile.fileName).to eq 'Solstice_Increasing.csv'

    expect(object1.columnNumber).to eq 2
    expect(object1.rowstoSkipatTop).to eq 1
    expect(object1.columnSeparator).to eq 'Comma'
    expect(object1.interpolatetoTimestep).to eq false
    expect(object1.minutesperItem.empty?).to eq false
    expect(object1.minutesperItem.get).to eq '10' # 6 timesteps per hour -> 10 minutes per timestep

    schedule_csv = schedule_csvs['Solstice Increasing_6_21_6']
    expect(schedule_csv).not_to be nil
    filename = schedule_csv[:filename]
    expect(filename).to eq 'Solstice_Increasing.csv'
    columns = schedule_csv[:columns]
    expect(columns.size).to eq 2
    expect(columns[0].size).to eq 8760 * 6 + 1
    expect(columns[1].size).to eq 8760 * 6 + 1

    Honeybee.write_schedule_csv(schedule_file_dir, schedule_csv)
  end

  it 'can export a schedule csv for a leap year' do
    schedule_dir = File.join(File.dirname(__FILE__), '..', 'output', 'schedule_osms')
    schedule_file_dir = File.join(schedule_dir, 'schedule_fixedinterval_leap_year')

    # translate to schedule file
    if File.directory?(schedule_file_dir)
      FileUtils.rm_rf(schedule_file_dir)
    end
    FileUtils.mkdir_p(schedule_file_dir)

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2016)
    workflow = openstudio_model.workflowJSON
    workflow.addFilePath(schedule_file_dir)
    openstudio_model.setWorkflowJSON(workflow)

    year_description = openstudio_model.getYearDescription
    year_description.setIsLeapYear(true)

    schedule_csvs = {}

    file = File.join(File.dirname(__FILE__), '../samples/schedule/schedule_fixedinterval_leap_year.json')
    honeybee_obj_1 = Honeybee::ScheduleFixedIntervalAbridged.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio(openstudio_model, schedule_file_dir, true, schedule_csvs)
    expect(object1).not_to be nil

    externalFile = object1.externalFile
    expect(externalFile.fileName).to eq 'Weekly_Temperature.csv'

    expect(object1.columnNumber).to eq 2
    expect(object1.rowstoSkipatTop).to eq 1
    expect(object1.columnSeparator).to eq 'Comma'
    expect(object1.interpolatetoTimestep).to eq false
    expect(object1.minutesperItem.empty?).to eq false
    expect(object1.minutesperItem.get).to eq '60' # 1 timesteps per hour -> 60 minutes per timestep

    schedule_csv = schedule_csvs['Weekly Temperature_2_29_1']
    expect(schedule_csv).not_to be nil
    filename = schedule_csv[:filename]
    expect(filename).to eq 'Weekly_Temperature.csv'
    columns = schedule_csv[:columns]
    expect(columns.size).to eq 2
    expect(columns[0].size).to eq 8784 + 1
    expect(columns[1].size).to eq 8784 + 1

    Honeybee.write_schedule_csv(schedule_file_dir, schedule_csv)
  end

end
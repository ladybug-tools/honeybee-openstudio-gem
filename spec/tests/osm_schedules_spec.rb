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

  # create output folder for HB JSON materials
  output_dir = File.join(File.dirname(__FILE__), '../output/osm_schedule/')
  FileUtils.mkdir_p(output_dir)

  it 'can load OSM and translate Schedule Type Limits to Honeybee' do

    file = File.join(File.dirname(__FILE__), '../samples/osm_schedule/scheduleTypeLimit.osm')
    vt = OpenStudio::OSVersion::VersionTranslator.new
    openstudio_model = vt.loadModel(file)

    # create HBJSON hash from OS model
    honeybee = Honeybee::Model.schedtypelimits_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'ScheduleTypeLimit'
    expect(honeybee[0][:identifier]).to eq 'Dimensionless'
    expect(honeybee[0][:lower_limit]).to eq 0
    expect(honeybee[0][:upper_limit]).to eq 1
    
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'scheduleTypeLimit.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

  it 'can load OSM and translate Schedule Ruleset to Honeybee' do 

    file = File.join(File.dirname(__FILE__), '../samples/osm_schedule/scheduleRuleset.osm')
    vt = OpenStudio::OSVersion::VersionTranslator.new
    openstudio_model = vt.loadModel(file)

    # create HBJSON hash from OS model
    honeybee = Honeybee::Model.scheduleruleset_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'ScheduleRulesetAbridged'
    expect(honeybee[0][:identifier]).to eq 'Schedule Ruleset 1'
    expect(honeybee[0][:default_day_schedule]).to eq 'Schedule Day 1'
    expect(honeybee[0][:summer_designday_schedule]).to eq 'Schedule Day 1'
    expect(honeybee[0][:winter_designday_schedule]).to eq 'Schedule Day 1'
    expect((honeybee[0][:day_schedules]).size).to eq 3
    expect((honeybee[0][:schedule_rules]).size).to eq 2

    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'scheduleRuleset.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

  it 'can load OSM and translate Schedule Fixed Interval to Honeybee' do

    file = File.join(File.dirname(__FILE__), '../samples/osm_schedule/scheduleFixedInterval.osm')

    vt = OpenStudio::OSVersion::VersionTranslator.new
    openstudio_model = vt.loadModel(file)

    # create HBJSON hash from OS model
    honeybee = Honeybee::Model.schedulefixedinterval_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'ScheduleFixedIntervalAbridged'
    expect(honeybee[0][:identifier]).to eq 'Random Occupancy'
    expect((honeybee[0][:start_date]).size).to eq 2
    expect(honeybee[0][:values].size).to eq 8760
    expect(honeybee[0][:timestep]).to eq 1
    expect(honeybee[0][:interpolate]).to eq false

    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'scheduleFixedInterval.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end

  end

end

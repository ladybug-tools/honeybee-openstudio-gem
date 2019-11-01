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

require_relative '../spec_helper'

RSpec.describe Ladybug::EnergyModel do
 
  it 'has a version number' do
    expect(Ladybug::EnergyModel::VERSION).not_to be nil
  end

  it 'has a measures directory' do
    extension = Ladybug::EnergyModel::Extension.new
    expect(File.exist?(extension.measures_dir)).to be true
  end

  it 'has a files directory' do
    extension = Ladybug::EnergyModel::Extension.new
    expect(File.exist?(extension.files_dir)).to be true
  end

  it 'has a valid schema' do
    extension = Ladybug::EnergyModel::Extension.new
    expect(extension.schema.nil?).to be false

    errors = extension.schema_validation_errors

    expect(extension.schema_valid?).to be true
    expect(extension.schema_validation_errors.empty?).to be true
  end

  it 'can load and validate multi zone office' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/model_multi_zone_office.json')
    model = Ladybug::EnergyModel::Model.read_from_disk(file)
   
    errors = model.validation_errors
    
    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = model.to_openstudio_model(openstudio_model)
  end

  it 'can load and validate single zone office' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/model_single_zone_office.json')
    model = Ladybug::EnergyModel::Model.read_from_disk(file)
   
    errors = model.validation_errors

    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = model.to_openstudio_model(openstudio_model)

    openstudio_spaces= openstudio_model.getBuilding.spaces
    expect(openstudio_spaces.empty?).to be false

    openstudio_space = openstudio_spaces[0]
    expect(openstudio_space.nameString).to eq 'TinyHouseZone'

    openstudio_space_type = openstudio_space.spaceType
    expect(openstudio_space_type.empty?).to be false

    openstudio_space_type = openstudio_space_type.get
    expect(openstudio_space_type.nameString).to eq 'Generic Office Program'

    openstudio_people = openstudio_space_type.people
    expect(openstudio_people.empty?).to be false

    openstudio_people = openstudio_people[0]

    #openstudio_people_definition = openstudio_people.peopleDefinition
    #expect(openstudio_people_definition.empty?).to be false

    openstudio_activity_schedule = openstudio_people.activityLevelSchedule
    expect(openstudio_activity_schedule.empty?).to be false

    openstudio_activity_schedule = openstudio_activity_schedule.get
    expect(openstudio_activity_schedule.nameString).to eq 'Generic Office Activity'

    schedule_type_limits = openstudio_activity_schedule.scheduleTypeLimits
    expect(schedule_type_limits.empty?).to be false

    schedule_type_limits = schedule_type_limits.get

    expect(schedule_type_limits.nameString).to eq 'Activity Level'   
  end

  it 'can load and validate a single zone office fixed interval original' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/model_single_zone_office_fixed_interval.json')
    model = Ladybug::EnergyModel::Model.read_from_disk(file)

    errors = model.validation_errors

    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = model.to_openstudio_model(openstudio_model)
    expect(openstudio_model).not_to be nil
  end

  it 'can load and validate single zone office fixed interval' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/model_single_zone_office copy.json')
    model = Ladybug::EnergyModel::Model.read_from_disk(file)
   
    errors = model.validation_errors

    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true
    
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = model.to_openstudio_model(openstudio_model)

    openstudio_spaces= openstudio_model.getBuilding.spaces
    expect(openstudio_spaces.empty?).to be false

    openstudio_space = openstudio_spaces[0]
    expect(openstudio_space.nameString).to eq 'TinyHouseZone'

    openstudio_space_type = openstudio_space.spaceType
    expect(openstudio_space_type.empty?).to be false

    openstudio_space_type = openstudio_space_type.get
    expect(openstudio_space_type.nameString).to eq 'Generic Office Program'

    openstudio_people = openstudio_space_type.people
    expect(openstudio_people.empty?).to be false

    openstudio_people = openstudio_people[0]

    openstudio_occupancy_schedule = openstudio_people.	numberofPeopleSchedule
    expect(openstudio_occupancy_schedule.empty?).to be false

    openstudio_occupancy_schedule = openstudio_occupancy_schedule.get
    expect(openstudio_occupancy_schedule.nameString).to eq 'Generic Office Occupancy' 
  end

  it 'can load and validate a schedule fixed interval' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/schedule_fixedinterval_increasing_single_day.json')
    model = Ladybug::EnergyModel::ScheduleFixedIntervalAbridged.read_from_disk(file)
  
    errors = model.validation_errors

    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true
    
    openstudio_model = model.to_openstudio(openstudio_model)
    expect(openstudio_model).not_to be nil
  end

  it 'can load and validate a schedule ruleset' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/schedule_ruleset_office_occupancy.json')
    model = Ladybug::EnergyModel::ScheduleRulesetAbridged.read_from_disk(file)
  
    errors = model.validation_errors

    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true
    
    openstudio_model = model.to_openstudio(openstudio_model)
    expect(openstudio_model).not_to be nil
  end

  it 'can load and validate a schedule type limit' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/scheduletypelimit_temperature.json')
    model = Ladybug::EnergyModel::ScheduleTypeLimit.read_from_disk(file)
  
    errors = model.validation_errors

    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true
    
    openstudio_model = model.to_openstudio(openstudio_model)
    expect(openstudio_model).not_to be nil
  end

end

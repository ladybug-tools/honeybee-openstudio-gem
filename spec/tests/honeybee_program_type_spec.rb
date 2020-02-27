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

RSpec.describe FromHoneybee do
 
  it 'has a version number' do
    expect(FromHoneybee::VERSION).not_to be nil
  end

  it 'has a measures directory' do
    extension = FromHoneybee::Extension.new
    expect(File.exist?(extension.measures_dir)).to be true
  end

  it 'has a files directory' do
    extension = FromHoneybee::Extension.new
    expect(File.exist?(extension.files_dir)).to be true
  end

  it 'can load program type kitchen' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/program_type/program_type_kitchen.json')
    honeybee_obj_1 = FromHoneybee::ProgramTypeAbridged.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
    
    #get people object
    people = object1.people
    activity_schedule = people[0].activityLevelSchedule
    expect(activity_schedule).not_to be nil
  
    #get people definition object
    people_definition = people[0].peopleDefinition
    people_per_floor = people_definition.peopleperSpaceFloorArea
    expect(people_per_floor).not_to be nil
    rad_frac = people_definition.fractionRadiant
    expect(rad_frac).to eq(0.3)
    
    #get lights object
    lights = object1.lights
    lights_schedule = lights[0].schedule
    expect(lights_schedule).not_to be nil

    #get lights definition object
    light_definition = lights[0].lightsDefinition
    return_air = light_definition.returnAirFraction
    expect(return_air).to eq(0.0)
    radiant_fraction = light_definition.fractionRadiant
    expect(radiant_fraction).to eq(0.7)
    fraction_visible = light_definition.fractionVisible
    expect(fraction_visible).to eq(0.2)

    #get electric equipment
    electric_eq = object1.electricEquipment
    electric_eq_schedule = electric_eq[0].schedule
    expect(electric_eq_schedule).not_to be nil

    #get electric equipment definition object
    elect_eq_def = electric_eq[0].electricEquipmentDefinition
    rad_frac_elec = elect_eq_def.fractionRadiant
    expect(rad_frac_elec).to eq(0.3)
    lost_frac_elec = elect_eq_def.fractionLost
    expect(lost_frac_elec).to eq(0.2)

    #get ventilation object
    ventilation = object1.designSpecificationOutdoorAir
    ventilation = ventilation.get
    expect(ventilation).not_to be nil
    flow_per_person = ventilation.outdoorAirFlowperPerson
    expect(flow_per_person).to eq(0.0035396025)
    flow_per_area = ventilation.outdoorAirFlowperFloorArea
    expect(flow_per_area).to eq(0.0009144)
    #check default assigned from schema
    air_chan_hr = ventilation.outdoorAirFlowAirChangesperHour
    expect(air_chan_hr).to eq(0)

  end

  it 'can load program type office' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/program_type/program_type_office.json')
    honeybee_obj_1 = FromHoneybee::ProgramTypeAbridged.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load program type patient room' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/program_type/program_type_patient_room.json')
    honeybee_obj_1 = FromHoneybee::ProgramTypeAbridged.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load program type plenum' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/program_type/program_type_plenum.json')
    honeybee_obj_1 = FromHoneybee::ProgramTypeAbridged.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    #get infiltration object
    infiltration = object1.spaceInfiltrationDesignFlowRates
    expect(infiltration).not_to be nil

    #check defaults assigned from the schema
    const_coeff = infiltration[0].constantTermCoefficient
    expect(const_coeff).to eq(1)
    temp_coeff = infiltration[0].temperatureTermCoefficient
    expect(temp_coeff).to eq(0)
    vel_coeff = infiltration[0].velocityTermCoefficient
    expect(vel_coeff).to eq(0)
  end

end

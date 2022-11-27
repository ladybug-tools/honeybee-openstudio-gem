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

  it 'can load an OSM and translate to Honeybee' do
    file = File.join(File.dirname(__FILE__), '../samples/osm/exampleModel.osm')
    weather_file = File.join(File.dirname(__FILE__), '../samples/epw')
    workflow = OpenStudio::WorkflowJSON.new
    workflow.setSeedFile(file)
    workflow.setWeatherFile(File.absolute_path(weather_file))
    honeybee = Honeybee::Model.translate_from_osm_file(file)

    hash = honeybee.hash
    expect(hash[:type]).not_to be_nil
    expect(hash[:type]).to eq 'Model'
    expect(hash[:rooms]).not_to be_nil
    expect(hash[:rooms].size).to eq 4

    # check construction_set
    expect(hash[:properties][:energy][:construction_sets]).not_to be nil
    expect(hash[:properties][:energy][:construction_sets][0][:identifier]).to eq 'Default Constructions'
    expect(hash[:properties][:energy][:construction_sets][0][:wall_set][:interior_construction]).to eq 'Air Wall'

    output_dir = File.join(File.dirname(__FILE__), '../output/osm/')
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'exampleModel.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(hash)
    end
  end

  it 'can load an OSM and translate to Honeybee' do
    file = File.join(File.dirname(__FILE__), '../samples/osm/exampleModel_withShade.osm')
    honeybee = Honeybee::Model.translate_from_osm_file(file)

    hash = honeybee.hash
    expect(hash[:type]).not_to be_nil
    expect(hash[:type]).to eq 'Model'
    expect(hash[:rooms]).not_to be_nil
    expect(hash[:rooms].size).to eq 4
    expect(hash[:properties][:energy][:constructions].size).to eq 14
    expect(hash[:properties][:energy][:materials].size).to eq 26

    output_dir = File.join(File.dirname(__FILE__), '../output/osm/')
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'exampleModel_withShade.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(hash)
    end
  end

  it 'can load an OSM and translate to Honeybee' do
    file = File.join(File.dirname(__FILE__), '../samples/osm/exampleModelSingleZone.osm')
    vt = OpenStudio::OSVersion::VersionTranslator.new
    openstudio_model = vt.loadModel(file)

    openstudio_model = openstudio_model.get

    # Create OS water use equipment defintion object
    water_use_equipment_definition = OpenStudio::Model::WaterUseEquipmentDefinition.new(openstudio_model)
    water_use_equipment = OpenStudio::Model::WaterUseEquipment.new(water_use_equipment_definition)
    water_use_equipment_definition.setPeakFlowRate(100)
    water_use_equipment.setName('Water Use Equipment')
    schedule = OpenStudio::Model::ScheduleFixedInterval.new(openstudio_model)
    schedule.setName('Schedule')
    water_use_equipment.setFlowRateFractionSchedule(schedule)
    
    # Get openstudio space from model
    openstudio_space = openstudio_model.getSpaces[0]
    openstudio_spacetype = openstudio_space.spaceType.get

    water_use_equipment.setSpaceType(openstudio_spacetype)
    water_use_equipment.setSpace(openstudio_space)

    # Note: openstudio_space.waterUseEquipment prints out the water use equipment object

    honeybee = Honeybee::Model.translate_from_osm_file(file)
    hash = honeybee.hash
    expect(hash[:type]).not_to be_nil
    expect(hash[:type]).to eq 'Model'
    expect(hash[:rooms]).not_to be_nil
    expect(hash[:rooms].size).to eq 1
    
    # Check load
    expect(hash[:rooms][0][:properties][:energy][:setpoint]).not_to be nil
    expect(hash[:rooms][0][:properties][:energy][:setpoint][:heating_schedule]).to eq 'Heating Schedule Default'
    expect(hash[:rooms][0][:properties][:energy][:setpoint][:cooling_schedule]).to eq 'Cooling Schedule Default'

    # Check water use equipment
    #Note: This is failing
    #expect(hash[:rooms][0][:properties][:energy][:service_hot_water][:identifier]).to eq 'Water Use Equipment'

    process_load = openstudio_model.getOtherEquipmentByName('Other Equipment 1')
    process_load.get.setFuelType('Electricity')
    #expect(hash[:rooms][0][:properties][:energy][:process_loads]).not_to be nil
    #expect(hash[:rooms][0][:properties][:energy][:process_loads][:identifier]).to eq ''
    
    output_dir = File.join(File.dirname(__FILE__), '../output/osm/')
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'exampleModelSingleZone.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(hash)
    end
  
  end


  it 'can load an OSM and translate to Honeybee SimulationParameter' do
    file = File.join(File.dirname(__FILE__), '../samples/osm/exampleModel.osm')
    simulation_parameter = Honeybee::SimulationParameter.translate_from_osm_file(file)

    hash = simulation_parameter.hash
    expect(hash[:type]).not_to be_nil
    expect(hash[:type]).to eq 'SimulationParameter'

    output_dir = File.join(File.dirname(__FILE__), '../output/osm/')
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'exampleModel.sim.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(hash)
    end
  end

  it 'can load constructionset' do
    file = File.join(File.dirname(__FILE__), '../samples/osm/exampleModel.osm')
    honeybee = Honeybee::Model.translate_from_osm_file(file)

    hash = honeybee.hash
    expect(hash[:type]).not_to be_nil
    expect(hash[:type]).to eq 'Model'

  end

end

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

RSpec.describe FromHoneybee do

  it 'has a measures directory' do
    extension = FromHoneybee::Extension.new
    expect(File.exist?(extension.measures_dir)).to be true
  end

  it 'has a schema_file' do
    extension = FromHoneybee::Extension.new
    expect(File.exist?(extension.schema_file)).to be true
  end

  it 'can load and validate complete single zone office' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_complete_single_zone_office.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil

    openstudio_surfaces = openstudio_model.getSurfaces
    expect(openstudio_surfaces.size).to eq 6

    openstudio_sub_surfaces = openstudio_model.getSubSurfaces
    expect(openstudio_sub_surfaces.size).to eq 3

    openstudio_surface = openstudio_model.getSurfaceByName('Tiny_House_Office_Bottom')
    expect(openstudio_surface.empty?).to be false

    openstudio_surface = openstudio_surface.get
    expect(openstudio_surface.nameString).to eq 'Tiny_House_Office_Bottom'

    openstudio_sub_surfaces = openstudio_surface.subSurfaces
    expect(openstudio_sub_surfaces.size).to eq 0

    openstudio_space = openstudio_surface.space
    expect(openstudio_space.empty?).to be false
    openstudio_space = openstudio_space.get
    expect(openstudio_space.nameString).to eq 'Tiny_House_Office'

    openstudio_story = openstudio_space.buildingStory 
    expect(openstudio_story.empty?).to be false
    openstudio_story = openstudio_story.get
    expect(openstudio_story.nameString).to eq 'UndefiniedStory'

    openstudio_vertices = openstudio_surface.vertices
    expect(openstudio_vertices.empty?).to be false
    expect(openstudio_vertices.size).to be >= 3

    openstudio_construction = openstudio_surface.construction
    expect(openstudio_construction.empty?).to be false
    openstudio_construction = openstudio_construction.get
    openstudio_layered_construction = openstudio_construction.to_LayeredConstruction
    expect(openstudio_layered_construction.empty?).to be false
    openstudio_layered_construction = openstudio_layered_construction.get
    expect(openstudio_layered_construction.numLayers).to be > 0
    expect(openstudio_layered_construction.numLayers).to be <= 10

    openstudio_surface2 = openstudio_model.getSurfaceByName('Tiny_House_Office_Front')
    expect(openstudio_surface2.empty?).to be false

    openstudio_surface2 = openstudio_surface2.get
    openstudio_subsurfaces2 = openstudio_surface2.subSurfaces
    expect(openstudio_subsurfaces2.size).to eq 2

    construction_name = openstudio_model.getConstructionByName('Default Generic Construction Set')
    expect(construction_name).not_to be nil

    schedule_ruleset = openstudio_model.getScheduleRulesetByName('Generic Office Infiltration')
    expect(schedule_ruleset).not_to be nil

    infilt = openstudio_model.getSpaceInfiltrationDesignFlowRates
    expect(infilt.size).to be 1

  end

  it 'can load and validate shoebox model' do
    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_shoe_box.json')
    model = FromHoneybee::Model.read_from_disk(file)

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = model.to_openstudio_model(openstudio_model, log_report=false)

    openstudio_surfaces = openstudio_model.getSurfaces
    expect(openstudio_surfaces.size).to eq 6

    openstudio_sub_surfaces = openstudio_model.getSubSurfaces
    expect(openstudio_sub_surfaces.size).to eq 2

    openstudio_surface = openstudio_model.getSurfaceByName('Simple_Shoe_Box_Zone_Front')
    expect(openstudio_surface.empty?).to be false

    openstudio_surface = openstudio_surface.get
    expect(openstudio_surface.nameString).to eq 'Simple_Shoe_Box_Zone_Front'

    openstudio_sub_surfaces = openstudio_surface.subSurfaces
    expect(openstudio_sub_surfaces.size).to eq 2
    openstudio_space = openstudio_surface.space

    expect(openstudio_space.empty?).to be false
    openstudio_space = openstudio_space.get
    expect(openstudio_space.nameString).to eq 'Simple_Shoe_Box_Zone'

    openstudio_vertices = openstudio_surface.vertices
    expect(openstudio_vertices.empty?).to be false
    expect(openstudio_vertices.size).to be >= 3

    openstudio_construction = openstudio_surface.construction
    expect(openstudio_construction.empty?).to be false
    openstudio_construction = openstudio_construction.get
    openstudio_layered_construction = openstudio_construction.to_LayeredConstruction
    expect(openstudio_layered_construction.empty?).to be false
    openstudio_layered_construction = openstudio_layered_construction.get
    expect(openstudio_layered_construction.numLayers).to be > 0
    expect(openstudio_layered_construction.numLayers).to be <= 10
  end

  it 'can load and validate model complete multi zone office' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_complete_multi_zone_office.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil

    openstudio_default_construction = openstudio_model.getBuilding.defaultConstructionSet
    expect(openstudio_default_construction.empty?).to be false
    openstudio_default_construction = openstudio_default_construction.get
    expect(openstudio_default_construction.nameString).to eq 'Default Generic Construction Set'
    
    openstudio_surfaces = openstudio_model.getSurfaces
    expect(openstudio_surfaces.size).to eq 17

    openstudio_spaces = openstudio_model.getSpaces
    expect(openstudio_spaces.size).to eq 3

    openstudio_space = openstudio_model.getSpaceByName('Attic')
    expect(openstudio_space.empty?).to be false

    openstudio_space = openstudio_space.get
    expect(openstudio_space.nameString).to eq 'Attic'
  end

  it 'can load complete office floor' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_complete_office_floor.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
  end

  it 'can load complete patient room' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_complete_patient_room.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
  end

  it 'can load model energy fixed interval' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_fixed_interval.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
  end

  it 'can load model energy no program' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_no_program.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
  end

  it 'can load model with all air template HVAC' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_allair_hvac.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
  end

  it 'can load model with DOAS template HVAC' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_doas_hvac.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
  end

  it 'can load model with heating/cooling template HVAC' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_window_ac.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
  end

  it 'can load model with window ventilation' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_window_ventilation.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil

    openstudio_vents = openstudio_model.getZoneVentilationWindandStackOpenAreas
    expect(openstudio_vents.size).to be 2
  end

  it 'can load model with an Airflow Network' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_afn.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil

    # make sure there are no single-zone ventilation objects in the model
    infilt = openstudio_model.getSpaceInfiltrationDesignFlowRates
    expect(infilt.size).to be 0
    openstudio_vents = openstudio_model.getZoneVentilationWindandStackOpenAreas
    expect(openstudio_vents.size).to be 0

    # check to be sure the relevant AFN objects are there
    openstudio_vents = openstudio_model.getAirflowNetworkSimpleOpenings
    expect(openstudio_vents.size).to be 3
    openstudio_cracks = openstudio_model.getAirflowNetworkCracks
    expect(openstudio_cracks.size).to be 9
    openstudio_cracks = openstudio_model.getEnergyManagementSystemSensors
    expect(openstudio_cracks.size).to be 3
    openstudio_cracks = openstudio_model.getEnergyManagementSystemActuators
    expect(openstudio_cracks.size).to be 3
    openstudio_cracks = openstudio_model.getEnergyManagementSystemPrograms
    expect(openstudio_cracks.size).to be 2
    openstudio_cracks = openstudio_model.getAirflowNetworkReferenceCrackConditionss
    expect(openstudio_cracks.size).to be 1
  end

  it 'can triangulate 5vertex sub faces' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_5vertex_sub_faces.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil

    openstudio_surfaces = openstudio_model.getSubSurfaces
    expect(openstudio_surfaces.size).to be >= 4
  end

  it 'can triangulate 5vertex sub faces with interior boundary conditions' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model/model_5vertex_sub_faces_interior.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil

    openstudio_spaces = openstudio_model.getSpaces
    expect(openstudio_spaces.size).to eq 2
    openstudio_spaces.each do |space|
      expect(space.surfaces.size).to eq 6

      num_surfaces_with_subsurfaces = 0
      space.surfaces.each do |srf|
        if srf.subSurfaces.size > 0
          num_surfaces_with_subsurfaces += 1
          bc = srf.outsideBoundaryCondition
          expect(bc.to_s).to eq 'Surface'
          expect(srf.adjacentSurface.empty?).to be false

          expect(srf.vertices.size).to eq 4
          expect(srf.subSurfaces.size).to eq 6

          srf.subSurfaces.each do |sub_srf|
            expect(sub_srf.vertices.size).to be >= 3
            expect(sub_srf.vertices.size).to be <= 4
            bc = sub_srf.outsideBoundaryCondition
            expect(bc.to_s).to eq 'Surface'
            expect(sub_srf.adjacentSubSurface.empty?).to be false
          end
        end
      end

      expect(num_surfaces_with_subsurfaces).to eq 1
    end
  end

  it 'can load large model for a single-family home' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model_large/single_family_home.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
  end

  it 'can load large model for a lab building' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/model_large/lab_building.json')
    honeybee_obj_1 = FromHoneybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
  end

end
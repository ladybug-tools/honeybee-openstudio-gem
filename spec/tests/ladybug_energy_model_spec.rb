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

  it 'can load and validate single zone model' do
    file = File.join(File.dirname(__FILE__), '../files/model_single_zone_tiny_house.json')
    model = Ladybug::EnergyModel::Model.read_from_disk(file)
   
    errors = model.validation_errors
    
    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true

    
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = model.to_openstudio_model(openstudio_model)


    openstudio_surfaces = openstudio_model.getSurfaces
    expect(openstudio_surfaces.size).to eq 6

    openstudio_sub_surfaces = openstudio_model.getSubSurfaces
    expect(openstudio_sub_surfaces.size).to eq 3

    openstudio_surface = openstudio_model.getSurfaceByName('TinyHouseZone_Bottom')
    expect(openstudio_surface.empty?).to be false

    openstudio_surface = openstudio_surface.get
    expect(openstudio_surface.nameString).to eq 'TinyHouseZone_Bottom'

    openstudio_sub_surfaces = openstudio_surface.subSurfaces
    expect(openstudio_sub_surfaces.size).to eq 0
    openstudio_space = openstudio_surface.space

    expect(openstudio_space.empty?).to be false
    openstudio_space = openstudio_space.get
    expect(openstudio_space.nameString).to eq 'TinyHouseZone'

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

  it 'can load and validate shoebox model' do
    file = File.join(File.dirname(__FILE__), '../files/model_shoe_box.json')
    model = Ladybug::EnergyModel::Model.read_from_disk(file)
        
    errors = model.validation_errors
    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = model.to_openstudio_model(openstudio_model)

    openstudio_surfaces = openstudio_model.getSurfaces
    expect(openstudio_surfaces.size).to eq 6

    openstudio_sub_surfaces = openstudio_model.getSubSurfaces
    expect(openstudio_sub_surfaces.size).to eq 2

    openstudio_surface = openstudio_model.getSurfaceByName('SimpleShoeBoxZone_Front')
    expect(openstudio_surface.empty?).to be false

    openstudio_surface = openstudio_surface.get
    expect(openstudio_surface.nameString).to eq 'SimpleShoeBoxZone_Front'

    openstudio_sub_surfaces = openstudio_surface.subSurfaces
    expect(openstudio_sub_surfaces.size).to eq 2
    openstudio_space = openstudio_surface.space

    expect(openstudio_space.empty?).to be false
    openstudio_space = openstudio_space.get
    expect(openstudio_space.nameString).to eq 'SimpleShoeBoxZone'

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

  it 'can load and validate mutizone model' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/model_multi_zone_single_family_house.json')
    
    model = Ladybug::EnergyModel::Model.read_from_disk(file)
    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true
    
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = model.to_openstudio_model(openstudio_model)

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
end
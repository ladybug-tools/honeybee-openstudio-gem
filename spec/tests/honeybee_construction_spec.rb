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
  it 'can load construction opaque door' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2020)
    file = File.join(File.dirname(__FILE__), '../samples/construction/construction_opaque_door.json')
    construction1 = Honeybee::OpaqueConstructionAbridged.read_from_disk(file)

    # get and set existing hash key
    expect(construction1.respond_to?(:identifier)).to be false
    expect(construction1.respond_to?(:identifier=)).to be false

    expect(construction1.identifier).to eq('Generic Exterior Door')

    # raise errors for non-existant hash keys an methods
    expect(construction1.respond_to?(:not_a_key)).to be false
    expect(construction1.respond_to?(:not_a_key=)).to be false
    expect{construction1.not_a_key }.to raise_error(NoMethodError)
    expect{construction1.not_a_key = 'Internal Floor'}.to raise_error(NoMethodError)

    object1 = construction1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load construction opaque roof' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2020)
    file = File.join(File.dirname(__FILE__), '../samples/construction/construction_opaque_roof.json')
    construction1 = Honeybee::OpaqueConstructionAbridged.read_from_disk(file)
    object1 = construction1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load construction opaque wall' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2020)
    file = File.join(File.dirname(__FILE__), '../samples/construction/construction_opaque_wall.json')
    construction1 = Honeybee::OpaqueConstructionAbridged.read_from_disk(file)
    object1 = construction1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load construction window construction with shade' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2020)
    file = File.join(File.dirname(__FILE__), '../samples/construction/construction_window_shade.json')
    construction1 = Honeybee::WindowConstructionShadeAbridged.read_from_disk(file)
    object1 = construction1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
    shd_cntrl = construction1.to_openstudio_shading_control(openstudio_model)
    expect(shd_cntrl.shadingType).to eq('InteriorShade')
  end

  it 'can load construction window construction with blinds' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2020)
    file = File.join(File.dirname(__FILE__), '../samples/construction/construction_window_blinds.json')
    construction1 = Honeybee::WindowConstructionShadeAbridged.read_from_disk(file)

    blind_mat_hash = Hash.new
    blind_mat_hash[:type] = "EnergyWindowMaterialBlind"
    blind_mat_hash[:identifier] = "Plastic Blind"
    material1 = Honeybee::EnergyWindowMaterialBlind.new(blind_mat_hash)
    blind_mat = material1.to_openstudio(openstudio_model)

    object1 = construction1.to_openstudio(openstudio_model)
    expect((object1.additionalProperties.featureNames)).to include ("DisplayName")
    #expect((object1.displayName.get)).to eq 'Double Low-E Outside Shade ({}|`^~!@\#$%^&*<>?-,!&~-)'
    expect(object1).not_to be nil
    shd_cntrl = construction1.to_openstudio_shading_control(openstudio_model)
    expect(shd_cntrl.shadingType).to eq('InteriorBlind')
  end

  it 'can load construction window double' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2020)
    file = File.join(File.dirname(__FILE__), '../samples/construction/construction_window_double.json')
    construction1 = Honeybee::WindowConstructionAbridged.read_from_disk(file)
    object1 = construction1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load construction window triple' do
    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2020)
    file = File.join(File.dirname(__FILE__), '../samples/construction/construction_window_triple.json')
    construction1 = Honeybee::WindowConstructionAbridged.read_from_disk(file)
    object1 = construction1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

end
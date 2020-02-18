# *******************************************************************************
# Honeybee Energy Model Measure, Copyright (c) 2020, Alliance for Sustainable 
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

  it 'can load opaque material brick' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_opaque_brick.json')
    material1 = FromHoneybee::EnergyMaterial.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load opaque material concrete' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_opaque_concrete.json')
    material1 = FromHoneybee::EnergyMaterial.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    thickness = object1.thickness
    expect(thickness).to eq(0.1)
    conductivity = object1.thermalConductivity
    expect(conductivity).to eq(0.53)
    roughness = object1.roughness
    expect(roughness).to eq('MediumRough')
    solar_absorptance = object1.thermalAbsorptance
    expect(solar_absorptance).to eq(0.9)
  end

  it 'can load opaque material gypsum' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_opaque_gypsum.json')
    material1 = FromHoneybee::EnergyMaterial.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load opaque insulation' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_opaque_insulation.json')
    material1 = FromHoneybee::EnergyMaterial.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load opaque wall gap' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_opaque_wall_gap.json')
    material1 = FromHoneybee::EnergyMaterialNoMass.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load material window blind' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_window_blind.json')
    material1 = FromHoneybee::EnergyWindowMaterialBlind.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load material window gas custom' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_window_gas_custom.json')
    material1 = FromHoneybee::EnergyWindowMaterialGasCustom.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load material window gas mixture' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_window_gas_mixture.json')
    material1 = FromHoneybee::EnergyWindowMaterialGasMixture.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load material window gas' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_window_gas.json')
    material1 = FromHoneybee::EnergyWindowMaterialGas.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil

    thickness = object1.thickness
    expect(thickness).to eq(0.0127)
    gas_type = object1.gasType
    expect(gas_type).to eq('Air')
  end

  it 'can load material window glazing clear' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_window_glazing_clear.json')
    material1 = FromHoneybee::EnergyWindowMaterialGlazing.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load material window glazing lowe' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_window_glazing_lowe.json')
    material1 = FromHoneybee::EnergyWindowMaterialGlazing.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load material window glazing system' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_window_glazing_system.json')
    material1 = FromHoneybee::EnergyWindowMaterialSimpleGlazSys.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load material window shade' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/material/material_window_shade.json')
    material1 = FromHoneybee::EnergyWindowMaterialShade.read_from_disk(file)
    object1 = material1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

end
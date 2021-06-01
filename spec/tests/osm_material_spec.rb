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

def load_file(file_name)
  # point to sample osm file
  file = File.join(File.dirname(__FILE__), '../samples/osm_material/', file_name)
  vt = OpenStudio::OSVersion::VersionTranslator.new
  osm = vt.loadModel(file)
  return osm
end

RSpec.describe Honeybee do

  # create output folder for HB JSON materials
  output_dir = File.join(File.dirname(__FILE__), '../output/osm_material/')
  FileUtils.mkdir_p(output_dir)

  it 'can load OSM and translate StandardOpaqueMaterial  to Honeybee' do

    openstudio_model = load_file('energyMaterial.osm')

    # create HB JSON material from OS model
    honeybee = Honeybee::Model.materials_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'EnergyMaterial'
    expect(honeybee[0][:identifier]).to eq '1/2IN Gypsum'
    expect(honeybee[0][:conductivity]).to eq 0.16
    
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'energyMaterial.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end

  end

  it 'can load OSM and translate MasslessOpaqueMaterial to Honeybee' do

    openstudio_model = load_file('matNoMass.osm')

    # create HB JSON material from OS model
    honeybee = Honeybee::Model.materials_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'EnergyMaterialNoMass'
    expect(honeybee[0][:identifier]).to eq 'CP02 CARPET PAD'
    expect(honeybee[0][:roughness]).to eq 'Smooth'

    File.open(File.join(output_dir,'energyMaterialNoMass.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

  it 'can load OSM and translate SimpleGlazingSystem to Honeybee' do
    openstudio_model = load_file('simGlazSys.osm')

    # create HB JSON material from OS model
    honeybee = Honeybee::Model.materials_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'EnergyWindowMaterialSimpleGlazSys'
    expect(honeybee[0][:identifier]).to eq 'Simple Glazing'
    expect(honeybee[0][:shgc]).to eq 0.39

    File.open(File.join(output_dir,'simGlazSys.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

  it 'can load OSM and translate WindowMaterialGlazing to Honeybee' do
    openstudio_model = load_file('winMatGlaz.osm')

    # create HB JSON material from OS model
    honeybee = Honeybee::Model.materials_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'EnergyWindowMaterialGlazing'
    expect(honeybee[0][:identifier]).to eq 'Clear 3mm'
    expect(honeybee[0][:solar_transmittance]).to eq 0.837
    expect(honeybee[0][:emissivity]).to eq 0.84
    expect(honeybee[0][:dirt_correction]).to eq 1

    File.open(File.join(output_dir,'winMatGlaz.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

  it 'can load OSM and translate WindowMaterialBlind to Honeybee' do
    openstudio_model = load_file('winMatBlind.osm')

    # create HB JSON material from OS model
    honeybee = Honeybee::Model.materials_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'EnergyWindowMaterialBlind'
    expect(honeybee[0][:identifier]).to eq 'Window Material Blind 1'
    expect(honeybee[0][:slat_width]).to eq 0.025
    expect(honeybee[0][:slat_separation]).to eq 0.01875
    expect(honeybee[0][:beam_solar_reflectance]).to eq 0.5

    File.open(File.join(output_dir,'winMatBlind.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

  it 'can load OSM and translate WindowMaterialGas to Honeybee' do
    openstudio_model = load_file('winMatGas.osm')

    # create HB JSON material from OS model
    honeybee = Honeybee::Model.materials_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'EnergyWindowMaterialGas'
    expect(honeybee[0][:identifier]).to eq 'Window Material Gas 1'
    expect(honeybee[0][:thickness]).to eq 0.003
    expect(honeybee[0][:gas_type]).to eq 'Air'

    File.open(File.join(output_dir,'winMatGas.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

  it 'can load OSM and translate WindowMaterialGasCustom to Honeybee' do
    openstudio_model = load_file('winMatGasCustom.osm')

    # create HB JSON material from OS model
    honeybee = Honeybee::Model.materials_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'EnergyWindowMaterialGasCustom'
    expect(honeybee[0][:identifier]).to eq 'Window Material Gas Custom'
    expect(honeybee[0][:thickness]).to eq 0.003
    expect(honeybee[0][:conductivity_coeff_a]).to eq 0.0146
    expect(honeybee[0][:specific_heat_coeff_a]).to eq 827.73
    expect(honeybee[0][:molecular_weight]).to eq 44

    File.open(File.join(output_dir,'winMatGasCustom.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

  it 'can load OSM and translate WindowMaterialGasMixture to Honeybee' do
    openstudio_model = load_file('winMatGasMixture.osm')

    # create HB JSON material from OS model
    honeybee = Honeybee::Model.materials_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'EnergyWindowMaterialGasMixture'
    expect(honeybee[0][:identifier]).to eq 'Window Material Gas Mixture 1'
    expect(honeybee[0][:thickness]).to eq 0.003

    expect(honeybee[0][:gas_types][0]).to eq 'Air'
    expect(honeybee[0][:gas_fractions][0]).to eq 0.96
    expect(honeybee[0][:gas_types][2]).to eq 'Krypton'
    expect(honeybee[0][:gas_fractions][2]).to eq 0.03


    File.open(File.join(output_dir,'winMatGasMixture.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

  it 'can load AirGap OS Material and translate to EnergyMaterialNoMass Honeybee material' do

    openstudio_model = load_file('airGap.osm')

    # create HB JSON material from OS model
    honeybee = Honeybee::Model.materials_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'EnergyMaterialNoMass'
    expect(honeybee[0][:identifier]).to eq 'Material Air Gap 1'

    expect(honeybee[0][:roughness]).to eq 'MediumRough'
    expect(honeybee[0][:thermal_absorptance]).to eq 0.9
    expect(honeybee[0][:visible_absorptance]).to eq 0.7

    File.open(File.join(output_dir,'airGap.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

end

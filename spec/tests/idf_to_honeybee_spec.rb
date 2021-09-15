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

  it 'can load an IDF and translate to Honeybee' do
    file = File.join(File.dirname(__FILE__), '../samples/idf/5ZoneAirCooled.idf')
    honeybee = Honeybee::Model.translate_from_idf_file(file)

    honeybee.validation_errors.each {|error| puts error}

    expect(honeybee.valid?).to be true
    hash = honeybee.hash
    expect(hash[:type]).not_to be_nil
    expect(hash[:type]).to eq 'Model'
    expect(hash[:rooms]).not_to be_nil
    expect(hash[:rooms].size).to eq 6 # plenum is being translated to a room

    output_dir = File.join(File.dirname(__FILE__), '../output/idf/')
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'5ZoneAirCooled.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(hash)
    end
  end

  it 'can load an IDF and translate to Honeybee SimulationParameter' do
    file = File.join(File.dirname(__FILE__), '../samples/idf/5ZoneAirCooled.idf')
    simulation_parameter = Honeybee::SimulationParameter.translate_from_idf_file(file)

    simulation_parameter.validation_errors.each {|error| puts error}

    expect(simulation_parameter.valid?).to be true
    hash = simulation_parameter.hash
    expect(hash[:type]).not_to be_nil
    expect(hash[:type]).to eq 'SimulationParameter'

    output_dir = File.join(File.dirname(__FILE__), '../output/idf/')
    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'5ZoneAirCooled.sim.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(hash)
    end
  end
end

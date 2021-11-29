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
require 'openstudio'
RSpec.describe Honeybee do

  # create output folder for HB JSON materials
  output_dir = File.join(File.dirname(__FILE__), '../output/osm_construction_set/')
  FileUtils.mkdir_p(output_dir)

  it 'can load OSM and translate Construction Set to Honeybee' do
    
    file = File.join(File.dirname(__FILE__), '../samples/osm_construction_set/constructionSet.osm')
    vt = OpenStudio::OSVersion::VersionTranslator.new
    openstudio_model = vt.loadModel(file)
    year = 2020
    openstudio_model.get.getYearDescription.setCalendarYear(year.to_i)
    weather_file = File.join(File.dirname(__FILE__), '../samples/epw')
    workflow = OpenStudio::WorkflowJSON.new
    workflow.setSeedFile(file)
    workflow.setWeatherFile(File.absolute_path(weather_file))
    const_set = openstudio_model.get.getDefaultConstructionSetByName('189.1-2009 - CZ1 - Office')
    const_set = const_set.get
    const_set.setDisplayName('Test Name áéíóúüñ¿¡')
    # create HB JSON material from OS model
    honeybee = Honeybee::Model.constructionsets_from_model(openstudio_model.get)

    # check values
    expect(honeybee.size).to eq 1
    expect(honeybee).not_to be nil
    expect(honeybee[0][:type]).to eq 'ConstructionSetAbridged'
    expect(honeybee[0][:identifier]).to eq '189.1-2009 - CZ1 - Office'
    expect(honeybee[0][:display_name]).to eq 'Test Name áéíóúüñ¿¡'
    expect(honeybee[0][:wall_set]).not_to be nil
    expect(honeybee[0][:wall_set][:interior_construction]).to eq 'Interior Wall'
    expect(honeybee[0][:floor_set]).not_to be nil
    expect(honeybee[0][:floor_set][:exterior_construction]).to eq 'ExtSlabCarpet 4in ClimateZone 1-8'
    expect(honeybee[0])
    expect(honeybee[0][:roof_ceiling_set]).not_to be nil
    expect(honeybee[0][:roof_ceiling_set][:interior_construction]).to eq 'Interior Ceiling'

    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'constructionSet.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee[0])
    end
  end

end

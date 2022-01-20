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

    # create output folder for HB JSON program types
    output_dir = File.join(File.dirname(__FILE__), '../output/osm_spacetype/')
    FileUtils.mkdir_p(output_dir)

    it 'can load OSM and translate SpaceType to Honeybee' do

        file = File.join(File.dirname(__FILE__), '../samples/osm_program_type/programType.osm')
        vt = OpenStudio::OSVersion::VersionTranslator.new
        openstudio_model = vt.loadModel(file)
        openstudio_model = openstudio_model.get
        year = 2020
        openstudio_model.getYearDescription.setCalendarYear(year.to_i)
        weather_folder = File.join(File.dirname(__FILE__), '../samples/epw')
        epw = Dir.glob("#{weather_folder}/*.epw")
        epw_file = OpenStudio::EpwFile.new(epw[0])
        OpenStudio::Model::WeatherFile.setWeatherFile(openstudio_model, epw_file)
        # create HB JSON material from OS model
        honeybee = Honeybee::Model.programtype_from_model(openstudio_model)

        # check values
        expect(honeybee.size).to eq 1
        expect(honeybee).not_to be nil
        expect(honeybee[0][:type]).to eq 'ProgramTypeAbridged'
        expect(honeybee[0][:identifier]).to eq '189.1-2009 - Office - BreakRoom - CZ1-3'

        expect(honeybee[0][:people]).not_to be nil
        expect(honeybee[0][:people][:identifier]).to eq 'People 1'
        expect(honeybee[0][:people][:people_per_area]).to eq 0.5381955504417419
        expect(honeybee[0][:people][:occupancy_schedule]).to eq 'Office Misc Occ'

        expect(honeybee[0][:electric_equipment]).not_to be nil
        expect(honeybee[0][:electric_equipment][:identifier]).to eq '189.1-2009 - Office - BreakRoom - CZ1-3 Electric Equipment'
        expect(honeybee[0][:electric_equipment][:watts_per_area]).to eq 48.0070404585254
        expect(honeybee[0][:electric_equipment][:radiant_fraction]).to eq 0.0
        expect(honeybee[0][:electric_equipment][:schedule]).to eq 'Office Bldg Equip'

        expect(honeybee[0][:gas_equipment]).not_to be nil
        expect(honeybee[0][:gas_equipment][:identifier]).to eq 'Gas Equipment 1'
        expect(honeybee[0][:gas_equipment][:watts_per_area]).to eq 15.0
        expect(honeybee[0][:gas_equipment][:latent_fraction]).to eq 0.01
        expect(honeybee[0][:gas_equipment][:lost_fraction]).to eq 0.01

        expect(honeybee[0][:lighting]).not_to be nil
        expect(honeybee[0][:lighting][:identifier]).to eq '189.1-2009 - Office - BreakRoom - CZ1-3 Lights'
        expect(honeybee[0][:lighting][:schedule]).to eq 'Office Bldg Light'
        expect(honeybee[0][:lighting][:watts_per_area]).to eq 11.6250232500465
        expect(honeybee[0][:lighting][:visible_fraction]).to eq 0.0

        expect(honeybee[0][:infiltration]).not_to be nil
        expect(honeybee[0][:infiltration][:identifier]).to eq '189.1-2009 - Office - BreakRoom - CZ1-3 Infiltration'
        expect(honeybee[0][:infiltration][:flow_per_exterior_area]).to eq 0.00030226
        expect(honeybee[0][:infiltration][:schedule]).to eq 'Office Infil Quarter On'
        expect(honeybee[0][:infiltration][:constant_coefficient]).to eq 0.1
        expect(honeybee[0][:infiltration][:temperature_coefficient]).to eq 0.1

        expect(honeybee[0][:ventilation]).not_to be nil
        expect(honeybee[0][:ventilation][:identifier]).to eq '189.1-2009 - Office - BreakRoom - CZ1-3 Ventilation'
        expect(honeybee[0][:ventilation][:flow_per_person]).to eq 0.007079211648
        expect(honeybee[0][:ventilation][:flow_per_area]).to eq 0.1

        FileUtils.mkdir_p(output_dir)
        File.open(File.join(output_dir,'programType.hbjson'), 'w') do |f|
            f.puts JSON::pretty_generate(honeybee[0])
        end
    end

end
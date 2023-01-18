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

  # create output folder for HB JSON materials
  output_dir = File.join(File.dirname(__FILE__), '../output/osm_hvac/')
  FileUtils.mkdir_p(output_dir)

  it 'can translate OS ZoneHVACIdealLoadsAirSystem to Honeybee' do

    model = OpenStudio::Model::Model.new
    zone_ideal_loads = OpenStudio::Model::ZoneHVACIdealLoadsAirSystem.new(model)
    zone_ideal_loads.setName('hvac')
    zone_ideal_loads.setOutdoorAirEconomizerType('NoEconomizer')
    zone_ideal_loads.setDemandControlledVentilationType('none')
    zone_ideal_loads.setSensibleHeatRecoveryEffectiveness(1)
    zone_ideal_loads.setLatentHeatRecoveryEffectiveness(1)
    zone_ideal_loads.setMaximumHeatingSupplyAirTemperature(99)
    zone_ideal_loads.setMinimumCoolingSupplyAirTemperature(-99)
    zone_ideal_loads.setHeatingLimit('NoLimit')
    zone_ideal_loads.setCoolingLimit('NoLimit')
    # TODO : set heating/cooling availability schedule

    schedule = OpenStudio::Model::ScheduleRuleset.new(model)
    schedule.setName('schedule')
    zone_ideal_loads.setHeatingAvailabilitySchedule(schedule)
    zone_ideal_loads.setCoolingAvailabilitySchedule(schedule)

    # create HB JSON ideal air system from OS model
    honeybee = Honeybee::IdealAirSystemAbridged.from_hvac(zone_ideal_loads)


    # check values
    no_limit_hash = {type: 'NoLimit'}
    expect(honeybee).not_to be nil
    expect(honeybee[:type]).to eq 'IdealAirSystemAbridged'
    expect(honeybee[:identifier]).to eq 'hvac'
    expect(honeybee[:economizer_type]).to eq 'NoEconomizer'
    expect(honeybee[:demand_controlled_ventilation]).to eq false
    expect(honeybee[:sensible_heat_recovery]).to eq 1.0
    expect(honeybee[:latent_heat_recovery]).to eq 1.0
    expect(honeybee[:heating_air_temperature]).to eq 99.0
    expect(honeybee[:cooling_air_temperature]).to eq -99.0
    expect(honeybee[:heating_limit]).to eq no_limit_hash
    expect(honeybee[:cooling_limit]).to eq no_limit_hash
    expect(honeybee[:heating_availability]).to eq 'schedule'
    expect(honeybee[:cooling_availability]).to eq 'schedule'

    FileUtils.mkdir_p(output_dir)
    File.open(File.join(output_dir,'idealAirSystem.hbjson'), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee)
    end

  end

end

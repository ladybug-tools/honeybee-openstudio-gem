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
  it 'can load ideal air default' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/hvac/ideal_air_default.json')
    honeybee_obj_1 = Honeybee::IdealAirSystemAbridged.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1.coolingLimit).to eq 'LimitFlowRateAndCapacity'
    expect(object1.isMaximumCoolingAirFlowRateAutosized).to eq true
    expect(object1).not_to be nil
  end

  it 'can load ideal air detailed' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/hvac/ideal_air_detailed.json')
    honeybee_obj_1 = Honeybee::IdealAirSystemAbridged.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
    expect(object1.nameString).to eq 'Passive House HVAC System'
    expect(object1.maximumHeatingSupplyAirTemperature).to eq 40.0
    expect(object1.minimumCoolingSupplyAirTemperature).to eq 15.0
    expect(object1.outdoorAirEconomizerType).to eq 'DifferentialEnthalpy'
    expect(object1.heatingLimit).to eq 'LimitCapacity'
    expect(object1.coolingLimit).to eq 'LimitFlowRateAndCapacity'
    expect(object1.demandControlledVentilationType).to eq 'OccupancySchedule'
  end

  it 'can load a VAV template system' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/hvac/vav_template.json')
    honeybee_obj_1 = Honeybee::TemplateHVAC.read_from_disk(file)
  end

  it 'can load a FCU with DOAS template system' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/hvac/fcu_with_doas_template.json')
    honeybee_obj_1 = Honeybee::TemplateHVAC.read_from_disk(file)
  end

  it 'can load a Window AC with Baseboard template system' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../samples/hvac/window_ac_with_baseboard_template.json')
    honeybee_obj_1 = Honeybee::TemplateHVAC.read_from_disk(file)
  end

end
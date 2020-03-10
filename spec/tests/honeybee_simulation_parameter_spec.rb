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
require 'from_honeybee/simulation/extension'

RSpec.describe FromHoneybee do
 
  it 'has a version number' do
    expect(FromHoneybee::VERSION).not_to be nil
  end

  it 'has a measures directory' do
    extension = FromHoneybee::ExtensionSimulationParameter.new
    expect(File.exist?(extension.measures_dir)).to be true
  end

  it 'has a files directory' do
    extension = FromHoneybee::ExtensionSimulationParameter.new
    expect(File.exist?(extension.files_dir)).to be true
  end

  it 'can load simple simulation parameter' do
    file = File.join(File.dirname(__FILE__), '../samples/simulation_parameter/simulation_par_simple.json')
    honeybee_obj_1 = FromHoneybee::SimulationParameter.read_from_disk(file)

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
  end


  it 'can load detailed simulation parameter' do
    file = File.join(File.dirname(__FILE__), '../samples/simulation_parameter/simulation_par_detailed.json')
    honeybee_obj_1 = FromHoneybee::SimulationParameter.read_from_disk(file)

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)

    sim_contr = openstudio_model.getSimulationControl

    expect(sim_contr.doZoneSizingCalculation).to be true
    expect(sim_contr.doSystemSizingCalculation).to be true
    expect(sim_contr.doPlantSizingCalculation).to be true
    expect(sim_contr.solarDistribution).to eq 'FullInteriorAndExteriorWithReflections'
    expect(sim_contr.sizingParameters).not_to be nil
    expect(sim_contr.runPeriods).not_to be nil

    sizing_par = openstudio_model.getSizingParameters
    expect(sizing_par.heatingSizingFactor).to eq 1
    expect(sizing_par.coolingSizingFactor).to eq 1

    run_period = openstudio_model.runPeriod
    run_period = run_period.get

    expect(run_period.getBeginDayOfMonth).to eq 1
    expect(run_period.getBeginMonth).to eq 1
    expect(run_period.getEndMonth).to eq 6
    expect(run_period.getEndDayOfMonth).to eq 21

    output_variable = openstudio_model.getOutputVariables
    expect(output_variable.size).to eq 6
    expect(output_variable[0].reportingFrequency).to eq 'Daily'
        
    shadow_calc = sim_contr.shadowCalculation
    shadow_calc = shadow_calc.get
    expect(shadow_calc.calculationFrequency).to eq 20
    expect(shadow_calc.calculationMethod).to eq 'AverageOverDaysInFrequency'
  end

end


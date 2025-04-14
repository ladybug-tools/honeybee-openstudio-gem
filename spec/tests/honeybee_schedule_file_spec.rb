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

require 'fileutils'

def set_simulation_parameters(openstudio_model, weather_name)

  weather_file_path = openstudio_model.workflowJSON.findFile(weather_name).get.to_s

  epw_file = OpenStudio::EpwFile.load(weather_file_path).get

  # Set weather file data
  weather_file = OpenStudio::Model::WeatherFile.setWeatherFile(openstudio_model, epw_file).get
  weather_file.makeUrlRelative
  weather_name = "#{weather_file.city}_#{weather_file.stateProvinceRegion}_#{weather_file.country}"

  # Add or update site data
  site = openstudio_model.getSite
  site.setName(weather_name)
  site.setLatitude(epw_file.latitude)
  site.setLongitude(epw_file.longitude)
  site.setTimeZone(epw_file.timeZone)
  site.setElevation(epw_file.elevation)

  # Remove all the Design Day objects that are in the file
  openstudio_model.getObjectsByType('OS:SizingPeriod:DesignDay'.to_IddObjectType).each(&:remove)

  # Load the ddy file
  ddy_file = "#{File.join(File.dirname(weather_file_path), File.basename(weather_file_path, '.*'))}.ddy"
  ddy_model = OpenStudio::EnergyPlus.loadAndTranslateIdf(ddy_file).get

  # Add the ddy objects to the existing model
  ddy_model.getDesignDays.sort.each {|d| openstudio_model.addObject(d.clone) }

  # Set the run period
  run_period = openstudio_model.getRunPeriod
  run_period.setBeginMonth(1)
  run_period.setBeginDayOfMonth(1)
  run_period.setEndMonth(12)
  run_period.setEndDayOfMonth(31)

  # Set the simulation control
  simulation_control = openstudio_model.getSimulationControl
  simulation_control.setDoZoneSizingCalculation(false)
  simulation_control.setDoSystemSizingCalculation(false)
  simulation_control.setDoPlantSizingCalculation(false)
  simulation_control.setRunSimulationforSizingPeriods(true)
  simulation_control.setRunSimulationforWeatherFileRunPeriods(true)

end


RSpec.describe Honeybee do

  it 'can translate model energy fixed interval to schedule file' do
    epw_name = 'USA_CO_Golden-NREL.724666_TMY3.epw'
    epw_dir = File.join(File.dirname(__FILE__), '..', 'samples', 'epw')
    schedule_dir = File.join(File.dirname(__FILE__), '..', 'output', 'schedule_osms')
    schedule_file_dir = File.join(schedule_dir, 'schedule_file')

    # translate to schedule file
    if File.directory?(schedule_file_dir)
      FileUtils.rm_rf(schedule_file_dir)
    end
    FileUtils.mkdir_p(schedule_file_dir)

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    workflow = openstudio_model.workflowJSON
    workflow.addFilePath(schedule_file_dir)
    workflow.addFilePath(epw_dir)
    workflow.setSeedFile('in.osm')
    workflow.setWeatherFile(epw_name)
    workflow.saveAs(File.join(schedule_file_dir, 'in.osw'))
    openstudio_model.setWorkflowJSON(workflow)

    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_fixed_interval.hbjson')
    honeybee_obj_1 = Honeybee::Model.read_from_disk(file)
    honeybee_obj_1.set_schedule_csv_dir(schedule_file_dir)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
    expect(File.file?(File.join(schedule_file_dir, 'Random_Occupancy.csv'))).to be true
    expect(File.file?(File.join(schedule_file_dir, 'Seasonal_Tree_Transmittance.csv'))).to be true

    set_simulation_parameters(openstudio_model, epw_name)

    openstudio_model.save(File.join(schedule_file_dir, 'in.osm'), true)

    command = "#{OpenStudio::getOpenStudioCLI} run -w #{File.join(schedule_file_dir, 'in.osw')}"
    puts command
    #result = system(command)
    #expect(result).to be true
  end

  it 'can translate model energy fixed interval to schedule file with datetimes' do
    epw_name = 'USA_CO_Golden-NREL.724666_TMY3.epw'
    epw_dir = File.join(File.dirname(__FILE__), '..', 'samples', 'epw')
    schedule_dir = File.join(File.dirname(__FILE__), '..', 'output', 'schedule_osms')
    schedule_file_dir = File.join(schedule_dir, 'schedule_file_with_datetimes')

    # translate to schedule file
    if File.directory?(schedule_file_dir)
      FileUtils.rm_rf(schedule_file_dir)
    end
    FileUtils.mkdir_p(schedule_file_dir)

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    workflow = openstudio_model.workflowJSON
    workflow.addFilePath(schedule_file_dir)
    workflow.addFilePath(epw_dir)
    workflow.setSeedFile('in.osm')
    workflow.setWeatherFile(epw_name)
    workflow.saveAs(File.join(schedule_file_dir, 'in.osw'))
    openstudio_model.setWorkflowJSON(workflow)

    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_fixed_interval.hbjson')
    honeybee_obj_1 = Honeybee::Model.read_from_disk(file)
    honeybee_obj_1.set_schedule_csv_dir(schedule_file_dir, true)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
    expect(File.file?(File.join(schedule_file_dir, 'Random_Occupancy.csv'))).to be true
    expect(File.file?(File.join(schedule_file_dir, 'Seasonal_Tree_Transmittance.csv'))).to be true

    set_simulation_parameters(openstudio_model, epw_name)

    openstudio_model.save(File.join(schedule_file_dir, 'in.osm'), true)

    command = "#{OpenStudio::getOpenStudioCLI} run -w #{File.join(schedule_file_dir, 'in.osw')}"
    puts command
    #result = system(command)
    #expect(result).to be true
  end

  it 'can translate model energy fixed interval to schedule fixed interval' do
    epw_name = 'USA_CO_Golden-NREL.724666_TMY3.epw'
    epw_dir = File.join(File.dirname(__FILE__), '..', 'samples', 'epw')
    schedule_dir = File.join(File.dirname(__FILE__), '..', 'output', 'schedule_osms')
    fixed_interval_dir = File.join(schedule_dir, 'fixed_interval')

    # translate to schedule fixed interval
    if File.directory?(fixed_interval_dir)
      FileUtils.rm_rf(fixed_interval_dir)
    end
    FileUtils.mkdir_p(fixed_interval_dir)

    openstudio_model = OpenStudio::Model::Model.new
    openstudio_model.getYearDescription.setCalendarYear(2017)
    workflow = openstudio_model.workflowJSON
    workflow.addFilePath(epw_dir)
    workflow.setSeedFile('in.osm')
    workflow.setWeatherFile(epw_name)
    workflow.saveAs(File.join(fixed_interval_dir, 'in.osw'))
    openstudio_model.setWorkflowJSON(workflow)

    file = File.join(File.dirname(__FILE__), '../samples/model/model_energy_fixed_interval.hbjson')
    honeybee_obj_1 = Honeybee::Model.read_from_disk(file)
    object1 = honeybee_obj_1.to_openstudio_model(openstudio_model, log_report=false)
    expect(object1).not_to be nil
    expect(Dir.glob(File.join(fixed_interval_dir, '*.csv')).empty?).to be true

    set_simulation_parameters(openstudio_model, epw_name)

    openstudio_model.save(File.join(fixed_interval_dir, 'in.osm'), true)

    command = "#{OpenStudio::getOpenStudioCLI} run -w #{File.join(fixed_interval_dir, 'in.osw')}"
    puts command
    #result = system(command)
    #expect(result).to be true
  end

end
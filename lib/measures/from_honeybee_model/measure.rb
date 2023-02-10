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

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

require 'to_openstudio'

require 'fileutils'
require 'pathname'
require 'json'

# start the measure
class FromHoneybeeModel < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    return 'From Honeybee Model'
  end

  # human readable description
  def description
    return 'Translate a JSON file of a Honeybee Model into an OpenStudio Model.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Translate a JSON file of a Honeybee Model into an OpenStudio Model.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Make an argument for the honyebee model json
    model_json = OpenStudio::Measure::OSArgument.makeStringArgument('model_json', true)
    model_json.setDisplayName('Path to the Honeybee Model JSON file')
    args << model_json

    # Make an argument for schedule csv dir
    schedule_csv_dir = OpenStudio::Measure::OSArgument.makeStringArgument('schedule_csv_dir', false)
    schedule_csv_dir.setDisplayName('Directory for exported CSV Schedules')
    schedule_csv_dir.setDescription('If set, Fixed Interval Schedules will be translated to CSV Schedules in this directory')
    schedule_csv_dir.setDefaultValue('')
    args << schedule_csv_dir

    # Make an argument for include datetimes
    include_datetimes = OpenStudio::Measure::OSArgument.makeBoolArgument('include_datetimes', false)
    include_datetimes.setDisplayName('Include date time column in exported CSV Schedules')
    include_datetimes.setDefaultValue(false)
    args << include_datetimes

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
    STDOUT.flush
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # get the input arguments
    model_json = runner.getStringArgumentValue('model_json', user_arguments)
    schedule_csv_dir = runner.getStringArgumentValue('schedule_csv_dir', user_arguments)
    include_datetimes = runner.getBoolArgumentValue('include_datetimes', user_arguments)

    # load the HBJSON file
    if !File.exist?(model_json)
      runner.registerError("Cannot find file '#{model_json}'")
      return false
    end
    honeybee_model = Honeybee::Model.read_from_disk(model_json)

    # setup the schedule directory
    if schedule_csv_dir && !schedule_csv_dir.empty?
      schedule_csv_dir = Pathname.new(schedule_csv_dir).cleanpath
      if !Dir.exist?(schedule_csv_dir)
        runner.registerError("Directory for exported CSV Schedules does not exist '#{schedule_csv_dir}'")
        return false
      end
      honeybee_model.set_schedule_csv_dir(schedule_csv_dir, include_datetimes)
    end

    # translate the Honeybee Model to OSM
    STDOUT.flush
    honeybee_model.to_openstudio_model(model)
    STDOUT.flush

    # if there are any detailed HVACs, incorproate them into the OSM
    generated_files_dir = "#{runner.workflow.absoluteRootDir}/generated_files"
    unless $detailed_hvac_hash.nil? || $detailed_hvac_hash.empty?
      runner.registerInfo("Translating Detailed HVAC systems in '#{generated_files_dir}'")
      if $ironbug_exe.nil?
        runner.registerError("No Ironbug installation was found on the system.")
      end
      FileUtils.mkdir_p(generated_files_dir)
      $detailed_hvac_hash.each do |hvac_id, hvac_spec|
        # write the JSON and OSM files
        hvac_json_path = generated_files_dir + '/' + hvac_id + '.json'
        osm_path = generated_files_dir + '/' + hvac_id + '.osm'
        File.open(hvac_json_path, 'w') do |f|
          f.write(hvac_spec.to_json)
        end
        model.save(osm_path, true)
        # call the Ironbug console to add the HVAC to the OSM
        ironbug_exe = '"' + $ironbug_exe + '"'
        system(ironbug_exe + ' "' + osm_path + '" "' + hvac_json_path + '"')
        # load the new model
        translator = OpenStudio::OSVersion::VersionTranslator.new
        o_model = translator.loadModel(osm_path)
        if o_model.empty?
          runner.registerError("Could not load Ironbug model from '" + osm_path.to_s + "'.")
          return false
        end
        new_model = o_model.get
        # replace the current model with the contents of the loaded model
        handles = OpenStudio::UUIDVector.new
        model.objects.each do |obj|
          handles << obj.handle
        end
        model.removeObjects(handles)
        # add new file to empty model
        model.addObjects(new_model.toIdfFile.objects)
      end
    end

    # if an efficiency standard has been set on the model, then run sizing and set everything
    building = model.getBuilding
    unless building.standardsTemplate.empty?
      puts 'Autosizing HVAC systems and assigning efficiencies'
      standard_id = building.standardsTemplate.get
      require 'openstudio-standards'
      standard = Standard.build(standard_id)
      # Set the heating and cooling sizing parameters
      standard.model_apply_prm_sizing_parameters(model)
      # Perform a sizing run
      if standard.model_run_sizing_run(model, "#{Dir.pwd}/SR1") == false
        log_messages_to_runner(runner, debug = true)
        return false
      end
      # If there are any multizone systems, reset damper positions
      # to achieve a 60% ventilation effectiveness minimum for the system
      # following the ventilation rate procedure from 62.1
      standard.model_apply_multizone_vav_outdoor_air_sizing(model)
      # get the climate zone  
      climate_zone_obj = model.getClimateZones.getClimateZone('ASHRAE', 2006)
      if climate_zone_obj.empty
        climate_zone_obj = model.getClimateZones.getClimateZone('ASHRAE', 2013)
      end
      climate_zone = climate_zone_obj.value
      # get the building type
      bldg_type = nil
      unless building.standardsBuildingType.empty?
        bldg_type = building.standardsBuildingType.get
      end
      # Apply the prototype HVAC assumptions
      standard.model_apply_prototype_hvac_assumptions(model, bldg_type, climate_zone)
      # Apply the HVAC efficiency standard
      standard.model_apply_hvac_efficiency_standard(model, climate_zone)
      puts 'Done with autosizing HVAC systems!'
    end

    puts 'Done with Model translation!'

    # copy the CSV schedules into the directory where EnergyPlus can find them
    if schedule_csv_dir && !schedule_csv_dir.empty?
      if Dir.exist?(schedule_csv_dir)
        runner.registerInfo("Copying exported schedules from '#{schedule_csv_dir}' to '#{generated_files_dir}'")
        FileUtils.mkdir_p(generated_files_dir)
        Dir.glob("#{schedule_csv_dir}/*.csv").each do |file|
          FileUtils.cp(file, generated_files_dir)
        end
      end
    end

    return true
  end
end

# register the measure to be used by the application
FromHoneybeeModel.new.registerWithApplication

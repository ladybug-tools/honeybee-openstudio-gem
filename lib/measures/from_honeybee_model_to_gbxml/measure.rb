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
require 'openstudio'

# start the measure
class FromHoneybeeModelToGbxml < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    return 'From Honeybee Model to gbXML'
  end

  # human readable description
  def description
    return 'Translate a JSON file of a Honeybee Model into a gbXML Model.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Translate a JSON file of a Honeybee Model into a gbXML Model.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Make an argument for the honyebee model json
    model_json = OpenStudio::Measure::OSArgument.makeStringArgument('model_json', true)
    model_json.setDisplayName('Path to the Honeybee Model JSON file')
    args << model_json

    # Make an argument for the output file path
    output_file_path = OpenStudio::Measure::OSArgument.makeStringArgument('output_file_path', false)
    output_file_path.setDisplayName('Output file path')
    output_file_path.setDescription('If set, the output gbXML file will be exported to this path. Othervise The file will be exported to the same path as the input model.')
    output_file_path.setDefaultValue('')
    args << output_file_path

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
    STDOUT.flush
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    # convert the Honeybee model into an OpenStudio Model
    model_json = runner.getStringArgumentValue('model_json', user_arguments)
    if !File.exist?(model_json)
      runner.registerError("Cannot find file '#{model_json}'")
      return false
    end
    honeybee_model = Honeybee::Model.read_from_disk(model_json)
    STDOUT.flush
    os_model = honeybee_model.to_openstudio_model(model)
    STDOUT.flush

    # make sure the zone name is different from the space name to comply with gbXML
    zones = os_model.getThermalZones()
    zones.each do |zone|
      zone_name = zone.name.to_s + '_Zone'
      zone.setName(zone_name)
    end

    # convert the OpenStudio model into a gbXML Model
    output_file_path = runner.getStringArgumentValue('output_file_path', user_arguments)
    if output_file_path && !output_file_path.empty?
      unless File.exist?(output_file_path)
        output_folder = File.split(output_file_path)[0]
        FileUtils.mkdir_p(output_folder)
      end
    else
      model_path, model_name = File.split(model_json)
      gbxml_model_name = model_name.split('.')[0] + '.gbxml'
      output_file_path = File.join(model_path, gbxml_model_name)
    end
    translator = OpenStudio::GbXML::GbXMLForwardTranslator.new
    translator.modelToGbXML(os_model, output_file_path)

    return true
  end
end

# register the measure to be used by the application
FromHoneybeeModelToGbxml.new.registerWithApplication

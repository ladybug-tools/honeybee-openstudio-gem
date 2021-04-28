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

require 'from_openstudio'

# start the measure
class FromOpenstudioModel < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    return "From Openstudio Model"
  end

  # human readable description
  def description
    return "Translate an OpenStudio Model into a JSON file of a Honeybee Model."
  end

  # human readable description of modeling approach
  def modeler_description
    return "Translate an OpenStudio Model into a JSON file of a Honeybee Model."
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Make an argument for the OpenStudio model
    openstudio_model = OpenStudio::Measure::OSArgument.makeStringArgument('openstudio_model', true)
    openstudio_model.setDisplayName('Path to the OpenStudio Model')
    args << openstudio_model

    # Make an argument for the output file path
    output_file_path = OpenStudio::Measure::OSArgument.makeStringArgument('output_file_path', true)
    output_file_path.setDisplayName('Output file path')
    output_file_path.setDescription('If set, the output Honeybee JSON file will be exported to this path. Othervise The file will be exported to the same path as the OpenStudio model.')
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

    openstudio_model = runner.getStringArgumentValue('openstudio_model', user_arguments)

    openstudio_model_path, openstudio_model_name = File.split(openstudio_model)
    honeybee_model_name = openstudio_model_name.split('.')[0] + '.hbjson'

    if !File.exist?(openstudio_model)
      runner.registerError("Cannot find file '#{openstudio_model}'")
      return false
    end

    honeybee_model = Honeybee::Model.translate_from_osm_file(openstudio_model)
    honeybee_hash = honeybee_model.hash

    output_file_path = runner.getStringArgumentValue('output_file_path', user_arguments)

    if output_file_path && !output_file_path.empty?
      unless File.exist?(output_file_path)
        output_folder = File.split(output_file_path)[0]
        FileUtils.mkdir_p(output_folder)
      end
    else
      output_file_path = File.join(openstudio_model_path, honeybee_model_name)
    end

    File.open(output_file_path, 'w') do |f|
      f.puts JSON::pretty_generate(honeybee_hash)
    end

    return true
  end
end

# register the measure to be used by the application
FromOpenstudioModel.new.registerWithApplication

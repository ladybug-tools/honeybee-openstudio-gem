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
class FromGbxmlModel < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    return "From Gbxml Model"
  end

  # human readable description
  def description
    return "Translate a gbXML into a JSON file of a Honeybee Model."
  end

  # human readable description of modeling approach
  def modeler_description
    return "Translate a gbXML into a JSON file of a Honeybee Model."
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Make an argument for the OpenStudio model
    gbxml_model = OpenStudio::Measure::OSArgument.makeStringArgument('gbxml_model', true)
    gbxml_model.setDisplayName('Path to the gbXML Model')
    args << gbxml_model

    # Make an argument for the output file path
    output_file_path = OpenStudio::Measure::OSArgument.makeStringArgument('output_file_path', true)
    output_file_path.setDisplayName('Output file path')
    output_file_path.setDescription('The output Honeybee JSON file will be exported to this path.')
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

    gbxml_model = runner.getStringArgumentValue('gbxml_model', user_arguments)

    gbxml_model_name = File.split(gbxml_model)[-1]
    honeybee_model_name = gbxml_model_name.split('.')[0] + '.json'

    if !File.exist?(gbxml_model)
      runner.registerError("Cannot find file '#{gbxml_model}'")
      return false
    end

    honeybee_model = Honeybee::Model.translate_from_gbxml_file(gbxml_model)
    honeybee_hash = honeybee_model.hash

    output_file_path = runner.getStringArgumentValue('output_file_path', user_arguments)

    unless File.exist?(output_file_path)
      FileUtils.mkdir_p(output_file_path)
    end

    File.open(File.join(output_file_path, honeybee_model_name), 'w') do |f|
      f.puts JSON::pretty_generate(honeybee_hash)
    end

    return true
  end
end

# register the measure to be used by the application
FromGbxmlModel.new.registerWithApplication

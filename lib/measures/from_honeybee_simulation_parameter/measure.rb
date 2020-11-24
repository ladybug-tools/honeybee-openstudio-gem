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

# start the measure
class FromHoneybeeSimulationParameter < OpenStudio::Measure::ModelMeasure
  # human readable name
  def name
    return 'From Honeybee Simulation Parameter'
  end

  # human readable description
  def description
    return 'Add a JSON file of Honeybee Simulationtion Parameters to an OpenStudio Model.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Add a JSON file of Honeybee Simulationtion Parameters to an OpenStudio Model.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Make an argument for the ladybug json
    simulation_parameter_json = OpenStudio::Measure::OSArgument.makeStringArgument('simulation_parameter_json', true)
    simulation_parameter_json.setDisplayName('Path to the Honeybee SimulationParameter JSON file')
    args << simulation_parameter_json

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
    STDOUT.flush
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    simulation_parameter_json = runner.getStringArgumentValue('simulation_parameter_json', user_arguments)

    if !File.exist?(simulation_parameter_json)
      runner.registerError("Cannot find file '#{simulation_parameter_json}'")
      return false
    end

    sim_par_object = Honeybee::SimulationParameter.read_from_disk(simulation_parameter_json)

    if !sim_par_object.valid?
      # runner.registerError("File '#{simulation_parameter_json}' is not valid")
      # return false
    end
    STDOUT.flush
    sim_par_object.to_openstudio_model(model)
    STDOUT.flush
    return true
  end
end

# register the measure to be used by the application
FromHoneybeeSimulationParameter.new.registerWithApplication

# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2018, Alliance for Sustainable Energy, LLC.
# All rights reserved.
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
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
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

require 'ladybug/Construction/construction'

# start the measure
class LadybugConstructionMeasure < OpenStudio::Measure::ModelMeasure

  # human readable name
  def name
    return 'Ladybug Construction Measure'
  end

  # human readable description
  def description
    return 'Ladybug Construction Measure.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'Ladybug Construction Measure.'
  end

  # define the arguments that the user will input
  def arguments(model)
    args = OpenStudio::Measure::OSArgumentVector.new

    # Make an argument for the ladybug json
    ladybug_json = OpenStudio::Measure::OSArgument.makeStringArgument('ladybug_json', true)
    ladybug_json.setDisplayName('Path to Ladybug JSON')
    args << ladybug_json

    return args
  end

  # define what happens when the measure is run
  def run(model, runner, user_arguments)
    super(model, runner, user_arguments)
puts "hello!"
STDOUT.flush
    if !runner.validateUserArguments(arguments(model), user_arguments)
      return false
    end

    ladybug_json = runner.getStringArgumentValue('ladybug_json', user_arguments)

    if !File.exists?(ladybug_json)
      runner.registerError("Cannot find file '#{ladybug_json}'")
      return false
    end
    
    ladybug_model = Ladybug::EnergyModel::Model.new(ladybug_json)
    
    if !ladybug_model.valid?
      #runner.registerError("File '#{ladybug_json}' is not valid")
      #return false
    end
    puts "lets go!"
STDOUT.flush
    ladybug_model.create_openstudio_objects(model)
    puts "done!"
STDOUT.flush
    return true
  end
end 

# register the measure to be used by the application
LadybugConstructionMeasure.new.registerWithApplication

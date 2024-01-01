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

require 'honeybee/generator/loadcenter'

require 'to_openstudio/model_object'

module Honeybee
  class ElectricLoadCenter

    def to_openstudio(openstudio_model, generator_objects)
      # create the ElectricLoadCenter:Distribution specification
      load_center = OpenStudio::Model::ElectricLoadCenterDistribution.new(openstudio_model)
      load_center.setName('Model Load Center Distribution')

      # add the generators to the specification
      generator_objects.each do |gen_obj|
        load_center.addGenerator(gen_obj)
      end

      # assign the major properties to the load center
      load_center.setGeneratorOperationSchemeType('Baseload')
      load_center.setElectricalBussType('DirectCurrentWithInverter')

      # create the inverter and assign it
      inverter = OpenStudio::Model::ElectricLoadCenterInverterPVWatts.new(openstudio_model)
      if @hash[:inverter_dc_to_ac_size_ratio]
        inverter.setDCToACSizeRatio(@hash[:inverter_dc_to_ac_size_ratio])
      else
        inverter.setDCToACSizeRatio(defaults[:inverter_dc_to_ac_size_ratio][:default])
      end
      if @hash[:inverter_efficiency]
        inverter.setInverterEfficiency(@hash[:inverter_efficiency])
      else
        inverter.setInverterEfficiency(defaults[:inverter_efficiency][:default])
      end
      load_center.setInverter(inverter)

      load_center
    end

  end #ElectricLoadCenter
end #Honeybee
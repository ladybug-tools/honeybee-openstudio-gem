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

require 'honeybee/ventcool/simulation'

require 'to_openstudio/model_object'

module Honeybee
  class VentilationSimulationControl

    def to_openstudio(openstudio_model)
      # create the AirflowNetworkSimulationControl object
      os_vsim_control = openstudio_model.getAirflowNetworkSimulationControl
      os_vsim_control.setName('Window Based Ventilative Cooling')

      # assign the control type
      if @hash[:vent_control_type]
        os_vsim_control.setAirflowNetworkControl(@hash[:vent_control_type])
      else
        os_vsim_control.setAirflowNetworkControl('MultizoneWithoutDistribution')
      end

      # assign the building type
      if @hash[:building_type]
        os_vsim_control.setBuildingType(@hash[:building_type])
      else
        os_vsim_control.setBuildingType(defaults[:building_type][:default])
      end

      # assign the long axis azimth angle of the building
      if @hash[:long_axis_angle]
        os_vsim_control.setAzimuthAngleofLongAxisofBuilding(@hash[:long_axis_angle])
      else
        os_vsim_control.setAzimuthAngleofLongAxisofBuilding(defaults[:long_axis_angle][:default])
      end

      # assign the aspect ratio of the building
      if @hash[:aspect_ratio]
        os_vsim_control.setBuildingAspectRatio(@hash[:aspect_ratio])
      else
        os_vsim_control.setBuildingAspectRatio(defaults[:aspect_ratio][:default])
      end

      # create the AirflowNetworkReferenceCrackConditions object that all other cracks reference
      os_ref_crack = OpenStudio::Model::AirflowNetworkReferenceCrackConditions.new(openstudio_model)
      os_ref_crack.setName('Reference Crack Conditions')

      # assign the reference temperature
      if @hash[:reference_temperature]
        os_ref_crack.setTemperature(@hash[:reference_temperature])
      else
        os_ref_crack.setTemperature(defaults[:reference_temperature][:default])
      end

      # assign the reference pressure
      if @hash[:reference_pressure]
        os_ref_crack.setBarometricPressure(@hash[:reference_pressure])
      else
        os_ref_crack.setBarometricPressure(defaults[:reference_pressure][:default])
      end

      # assign the reference humidity ratio
      if @hash[:reference_humidity_ratio]
        os_ref_crack.setHumidityRatio(@hash[:reference_humidity_ratio])
      else
        os_ref_crack.setHumidityRatio(defaults[:reference_humidity_ratio][:default])
      end

      os_ref_crack
    end

  end #VentilationSimulationControl
end #Honeybee
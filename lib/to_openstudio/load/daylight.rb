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

require 'honeybee/load/daylight'

require 'to_openstudio/model_object'

module Honeybee
  class DaylightingControl

    def find_existing_openstudio_object(openstudio_model, parent_space_name)
      dl_cntrl_name = parent_space_name + '_Daylighting'
      model_dl_cntrl = openstudio_model.getDaylightingControlByName(dl_cntrl_name)
      return model_dl_cntrl.get unless model_dl_cntrl.empty?
      nil
    end

    def to_openstudio(openstudio_model, parent_zone, parent_space)
      # create daylighting control openstudio object and set identifier
      os_dl_control = OpenStudio::Model::DaylightingControl.new(openstudio_model)
      space_name = parent_space.name
      unless space_name.empty?
        os_dl_control.setName(parent_space.name.get + '_Daylighting')
      end
      os_dl_control.setSpace(parent_space)
      parent_zone.setPrimaryDaylightingControl(os_dl_control)

      # assign the position of the sensor point
      os_dl_control.setPositionXCoordinate(@hash[:sensor_position][0])
      os_dl_control.setPositionYCoordinate(@hash[:sensor_position][1])
      os_dl_control.setPositionZCoordinate(@hash[:sensor_position][2])

      # assign the illuminance setpoint if it exists
      if @hash[:illuminance_setpoint]
        os_dl_control.setIlluminanceSetpoint(@hash[:illuminance_setpoint])
      else
        os_dl_control.setIlluminanceSetpoint(defaults[:illuminance_setpoint][:default])
      end

      # assign power fraction if it exists
      if @hash[:min_power_input]
        os_dl_control.setMinimumInputPowerFractionforContinuousDimmingControl(@hash[:min_power_input])
      else
        os_dl_control.setMinimumInputPowerFractionforContinuousDimmingControl(defaults[:min_power_input][:default])
      end

      # assign light output fraction if it exists
      if @hash[:min_power_input]
        os_dl_control.setMinimumLightOutputFractionforContinuousDimmingControl(@hash[:min_light_output])
      else
        os_dl_control.setMinimumLightOutputFractionforContinuousDimmingControl(defaults[:min_light_output][:default])
      end

      # set whether the lights go off when they reach their minimum
      if @hash[:off_at_minimum]
        os_dl_control.setLightingControlType('Continuous/Off')
      else
        os_dl_control.setLightingControlType('Continuous')
      end

      # set the fraction of the zone lights that are dimmed
      if @hash[:control_fraction]
        parent_zone.setFractionofZoneControlledbyPrimaryDaylightingControl(@hash[:control_fraction])
      else
        parent_zone.setFractionofZoneControlledbyPrimaryDaylightingControl(defaults[:control_fraction][:default])
      end

      os_dl_control
    end

  end #DaylightingControl
end #Honeybee

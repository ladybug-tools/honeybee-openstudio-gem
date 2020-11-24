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

require 'honeybee/load/setpoint_humidistat'

require 'to_openstudio/model_object'

module Honeybee
  class SetpointHumidistat

    def to_openstudio(openstudio_model)

      # create humidistat openstudio object
      os_humidistat = OpenStudio::Model::ZoneControlHumidistat.new(openstudio_model)

      # assign humidifying schedule if it exists
      if @hash[:humidifying_schedule]
        humid_sch = openstudio_model.getScheduleByName(@hash[:humidifying_schedule])
        unless humid_sch.empty?
          humid_sch_object = humid_sch.get
          os_humidistat.setHumidifyingRelativeHumiditySetpointSchedule(humid_sch_object)
        end
      end

      # assign dehumidifying schedule if it exists
      if @hash[:dehumidifying_schedule]
        dehumid_sch = openstudio_model.getScheduleByName(@hash[:dehumidifying_schedule])
        unless dehumid_sch.empty?
          dehumid_sch_object = dehumid_sch.get
          os_humidistat.setDehumidifyingRelativeHumiditySetpointSchedule(dehumid_sch_object)
        end
      end

      os_humidistat
    end

  end #SetpointHumidistat
end #Honeybee
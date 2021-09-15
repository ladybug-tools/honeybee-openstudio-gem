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

require 'honeybee/schedule/type_limit'
require 'to_openstudio/model_object'

module Honeybee
  class ScheduleTypeLimit < ModelObject

    def self.from_schedule_type_limit(schedule_type_limit)
      # create an empty hash
      hash = {}
      hash[:type] = 'ScheduleTypeLimit'
      # set hash values from OpenStudio Object
      hash[:identifier] = clean_name(schedule_type_limit.nameString)
      # check if boost optional object is empty
      unless schedule_type_limit.lowerLimitValue.empty?
        hash[:lower_limit] = schedule_type_limit.lowerLimitValue.get
      end
      # check if boost optional object is empty
      unless schedule_type_limit.upperLimitValue.empty?
        hash[:upper_limit] = schedule_type_limit.upperLimitValue.get
      end
      # check if boost optional object is empty
      unless schedule_type_limit.numericType.empty?
        numeric_type = schedule_type_limit.numericType.get
        hash[:numeric_type] = numeric_type.titleize
      end

      # make sure unit type always follows the capitalization of the Honeybee Enumeration
      unit_type = schedule_type_limit.unitType.titleize
      if unit_type == 'Deltatemperature'
        unit_type = 'DeltaTemperature'
      elsif unit_type == 'Precipitationrate'
        unit_type = 'PrecipitationRate'
      elsif unit_type == 'Convectioncoefficient'
        unit_type = 'ConvectionCoefficient'
      elsif unit_type == 'Activitylevel'
        unit_type = 'ActivityLevel'
      end
      hash[:unit_type] = unit_type

      hash
    end

  end # ScheduleTypeLimit
end # Honeybee

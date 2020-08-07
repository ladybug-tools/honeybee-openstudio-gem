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

require 'from_honeybee/extension'
require 'from_honeybee/model_object'

require 'openstudio'

module FromHoneybee
  class ScheduleTypeLimit < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)

      raise "Incorrect model type '#{@type}'" unless @type == 'ScheduleTypeLimit'
    end

    def defaults
      @@schema[:components][:schemas][:ScheduleTypeLimit][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getScheduleTypeLimitsByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create schedule type limits openstudio object
      os_type_limit = OpenStudio::Model::ScheduleTypeLimits.new(openstudio_model)
      os_type_limit.setName(@hash[:identifier])

      if @hash[:lower_limit] != nil and @hash[:lower_limit] != {:type => 'NoLimit'}
        os_type_limit.setLowerLimitValue(@hash[:lower_limit])
      end

      if @hash[:upper_limit] != nil and @hash[:upper_limit] != {:type => 'NoLimit'}
        os_type_limit.setUpperLimitValue(@hash[:upper_limit])
      end

      # assign numeric type
      if @hash[:numeric_type]
        os_type_limit.setNumericType(@hash[:numeric_type])
      else
        os_type_limit.setNumericType(defaults[:numeric_type])
      end

      # assign unit type
      if @hash[:unit_type]
        os_type_limit.setUnitType(@hash[:unit_type])
      else 
        os_type_limit.setUnitType(defaults[:unit_type])
      end
      
      os_type_limit
    end

  end # ScheduleTypeLimit
end # FromHoneybee

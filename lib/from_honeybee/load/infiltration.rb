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

module FromHoneybee
  class InfiltrationAbridged < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
      raise "Incorrect model type '#{@type}'" unless @type == 'InfiltrationAbridged'
    end
  
    def defaults
      @@schema[:components][:schemas][:InfiltrationAbridged][:properties]
    end
  
    def find_existing_openstudio_object(openstudio_model)
      model_infiltration = openstudio_model.getSpaceInfiltrationDesignFlowRateByName(@hash[:identifier])
      return model_infiltration.get unless model_infiltration.empty?
      nil
    end
  
    def to_openstudio(openstudio_model)    
      
      # create infiltration OpenStudio object and set identifier
      os_infilt = OpenStudio::Model::SpaceInfiltrationDesignFlowRate.new(openstudio_model)
      os_infilt.setName(@hash[:identifier])

      # assign flow per surface
      os_infilt.setFlowperExteriorSurfaceArea(@hash[:flow_per_exterior_area])

      # assign schedule
      infiltration_schedule = openstudio_model.getScheduleByName(@hash[:schedule])
      unless infiltration_schedule.empty?
        infiltration_schedule_object = infiltration_schedule.get
        os_infilt.setSchedule(infiltration_schedule_object)
      end

      # assign constant coefficient if it exists
      if @hash[:constant_coefficient]
        os_infilt.setConstantTermCoefficient(@hash[:constant_coefficient])
      else 
        os_infilt.setConstantTermCoefficient(defaults[:constant_coefficient][:default])
      end
      
      # assign temperature coefficient
      if @hash[:temperature_coefficient]
        os_infilt.setTemperatureTermCoefficient(@hash[:temperature_coefficient])
      else
        os_infilt.setTemperatureTermCoefficient(defaults[:temperature_coefficient][:default])
      end
      
      # assign velocity coefficient
      if @hash[:velocity_coefficient]
        os_infilt.setVelocityTermCoefficient(@hash[:velocity_coefficient])
      else 
        os_infilt.setVelocityTermCoefficient(defaults[:velocity_coefficient][:default])
      end

      os_infilt
    end
    
  end #InfiltrationAbridged
end #Ladybug
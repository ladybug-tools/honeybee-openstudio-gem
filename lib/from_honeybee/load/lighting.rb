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
  class LightingAbridged < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
      raise "Incorrect model type '#{@type}'" unless @type == 'LightingAbridged'
    end
  
    def defaults
      @@schema[:components][:schemas][:LightingAbridged][:properties]
    end
  
    def find_existing_openstudio_object(openstudio_model)
      model_lights = openstudio_model.getLightsDefinitionByName(@hash[:identifier])
      return model_lights.get unless model_lights.empty?
      nil
    end
  
    def to_openstudio(openstudio_model)

      # create lights OpenStudio object and set identifier
      os_lights_def = OpenStudio::Model::LightsDefinition.new(openstudio_model)
      os_lights = OpenStudio::Model::Lights.new(os_lights_def)
      os_lights_def.setName(@hash[:identifier])
      os_lights.setName(@hash[:identifier])

      # assign watts per space floor area
      os_lights_def.setWattsperSpaceFloorArea(@hash[:watts_per_area])

      # assign lighting schedule
      lighting_schedule = openstudio_model.getScheduleByName(@hash[:schedule])
      unless lighting_schedule.empty?
        lighting_schedule_object = lighting_schedule.get
        os_lights.setSchedule(lighting_schedule_object)
      end

      # assign visible fraction if it exists
      if @hash[:visible_fraction]
        os_lights_def.setFractionVisible(@hash[:visible_fraction])
      else
        os_lights_def.setFractionVisible(defaults[:visible_fraction][:default])
      end

      # assign radiant fraction if it exists
      if @hash[:radiant_fraction]
        os_lights_def.setFractionRadiant(@hash[:radiant_fraction])
      else
        os_lights_def.setFractionRadiant(defaults[:radiant_fraction][:default])
      end

      # assign return air fraction if it exists
      if @hash[:return_air_fraction]
        os_lights_def.setReturnAirFraction(@hash[:return_air_fraction])
      else 
        os_lights_def.setReturnAirFraction(defaults[:return_air_fraction][:default])
      end

      os_lights
    end

  end #LightingAbridged
end #FromHoneybee


# *******************************************************************************
# Ladybug Tools Energy Model Schema, Copyright (c) 2019, Alliance for Sustainable
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

require "#{File.dirname(__FILE__)}/extension"
require "#{File.dirname(__FILE__)}/model_object"

module Ladybug
  module EnergyModel
    class LightingAbridged < ModelObject
      attr_reader :errors, :warnings
  
      def initialize(hash = {})
        super(hash)
        raise "Incorrect model type '#{@type}'" unless @type == 'LightingAbridged'
      end
    
      def defaults
        result = {}
        result
      end
    
      def find_existing_openstudio_object(openstudio_model)
        model_lights = openstudio_model.getLightsDefinitionByName(@hash[:name])
        return model_lights.get unless model_lights.empty?
        nil
      end
    
      def create_openstudio_object(openstudio_model)
        openstudio_lights_definition = OpenStudio::Model::LightsDefinition.new(openstudio_model)
        openstudio_lights_definition.setWattsperSpaceFloorArea(@hash[:watts_per_area])
        if @hash[:visible_fraction]
          openstudio_lights_definition.setFractionVisible(@hash[:visible_fraction])
        else
          openstudio_lights_definition.setFractionVisible(@@schema[:definitions][:LightingAbridged][:properties][:visible_fraction][:default])
        end
        if @hash[:radiant_fraction]
          openstudio_lights_definition.setFractionRadiant(@hash[:radiant_fraction])
        else
          openstudio_lights_definition.setFractionRadiant(@@schema[:definitions][:LightingAbridged][:properties][:radiant_fraction][:default])
        end
        if @hash[:return_air_fraction]
          openstudio_lights_definition.setReturnAirFraction(@hash[:return_air_fraction])
        else 
          openstudio_lights_definition.setReturnAirFraction(@@schema[:definitions][:LightingAbridged][:properties][:return_air_fraction][:default])
        end
          
        openstudio_lights = OpenStudio::Model::Lights.new(openstudio_lights_definition)
        openstudio_lights.setName(@hash[:name])
        openstudio_lights.setLightsDefinition(openstudio_lights_definition)

        lighting_schedule = openstudio_model.getScheduleByName(@hash[:schedule])
        unless lighting_schedule.empty?
          lighting_schedule_object = lighting_schedule.get
        end         
        openstudio_lights.setSchedule(lighting_schedule_object)
        
        openstudio_lights
      end

    end #LightingAbridged
  end #EnergyModel
end #Ladybug


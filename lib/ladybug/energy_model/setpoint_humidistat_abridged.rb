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

require 'ladybug/energy_model/extension'
require 'ladybug/energy_model/model_object'

module Ladybug
  module EnergyModel
    class SetpointHumidistatAbridged < ModelObject
      attr_reader :errors, :warnings
  
      def initialize(hash = {})
        super(hash)
        raise "Incorrect model type '#{@type}'" unless @type == 'SetpointAbridged'
      end
    
      def defaults
        result = {}
        result
      end
    
      def find_existing_openstudio_object(openstudio_model)
        #model_setpoint_humidistat = openstudio_model.getModelObjectByName(@hash[:name])
        #return model_setpoint_humidistat.get unless model_setpoint_humidistat.empty?
        #nil
      end
    
      def create_openstudio_object(openstudio_model)
        openstudio_setpoint_humidistat = OpenStudio::Model::ZoneControlHumidistat.new(openstudio_model)
        openstudio_setpoint_humidistat.setName(@hash[:name])
        
        if @hash[:humidification_schedule]
          humidification_schedule_object = nil
          humidification_schedule = openstudio_model.getScheduleByName(@hash[:humidification_schedule])
          unless humidification_schedule.empty?
            humidification_schedule_object = humidification_schedule.get
          end
          openstudio_setpoint_humidistat.setHumidifyingRelativeHumiditySetpointSchedule(humidification_schedule_object)
        end
          
        if @hash[:dehumidification_schedule]
          dehumidification_schedule_object = nil
          dehumidification_schedule = openstudio_model.getScheduleByName(@hash[:dehumidification_schedule])
          unless dehumidification_schedule.empty?
            dehumidification_schedule_object = dehumidification_schedule.get
          end
          openstudio_setpoint_humidistat.setDehumidifyingRelativeHumiditySetpointSchedule(dehumidification_schedule_object)
        end

        openstudio_setpoint_humidistat
      end

    end #SetpointHumidistatAbridged
  end #EnergyModel
end #Ladybug
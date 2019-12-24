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
    class VentilationAbridged < ModelObject
      attr_reader :errors, :warnings
  
      def initialize(hash = {})
        super(hash)
        raise "Incorrect model type '#{@type}'" unless @type == 'VentilationAbridged'
      end
    
      def defaults
        result = {}
        result
      end
    
      def find_existing_openstudio_object(openstudio_model)
        model_ventilation = openstudio_model.getDesignSpecificationOutdoorAirByName(@hash[:name])
        return model_ventilation.get unless model_ventilation.empty?
        nil
      end
    
      def create_openstudio_object(openstudio_model)       
        openstudio_ventilation = OpenStudio::Model::DesignSpecificationOutdoorAir.new(openstudio_model)
        openstudio_ventilation.setName(@hash[:name])
        if @hash[:air_changes_per_hour]
          openstudio_ventilation.setOutdoorAirFlowAirChangesperHour(@hash[:air_changes_per_hour])
        else
          openstudio_ventilation.setOutdoorAirFlowAirChangesperHour(@@schema[:definitions][:VentilationAbridged][:properties][:air_changes_per_hour][:default])
        end
        if @hash[:flow_per_zone]
          openstudio_ventilation.setOutdoorAirFlowRate(@hash[:flow_per_zone])
        else
          openstudio_ventilation.setOutdoorAirFlowRate(@@schema[:definitions][:VentilationAbridged][:properties][:flow_per_zone][:default])
        end
        if @hash[:flow_per_person]
          openstudio_ventilation.setOutdoorAirFlowperPerson(@hash[:flow_per_person])
        end
        if @hash[:flow_per_area]
          openstudio_ventilation.setOutdoorAirFlowperFloorArea(@hash[:flow_per_area])
        end
        if @hash[:schedule]
          ventilation_scheule = openstudio_model.getScheduleByName(@hash[:schedule])
          unless ventilation_schedule.empty?
            ventilation_schedule_object = ventilation_schedule.get
          end
          openstudio_ventilation.setOutdoorAirFlowRateFractionSchedule(ventilation_schedule_object)
        end

        openstudio_ventilation
      end

    end #VentilationAbridged
  end #EnergyModel
end #Ladybug
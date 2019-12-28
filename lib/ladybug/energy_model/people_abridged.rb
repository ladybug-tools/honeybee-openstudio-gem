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
    class PeopleAbridged < ModelObject
      attr_reader :errors, :warnings
  
      def initialize(hash = {})
        super(hash)
        raise "Incorrect model type '#{@type}'" unless @type == 'PeopleAbridged'
      end
    
      def defaults
        result = {}
        result
      end
    
      def find_existing_openstudio_object(openstudio_model)
        model_people = openstudio_model.getPeopleDefinitionByName(@hash[:name])
        return model_people.get unless model_people.empty?
        nil
      end
    
      def create_openstudio_object(openstudio_model)
        openstudio_people_definition = OpenStudio::Model::PeopleDefinition.new(openstudio_model)
        openstudio_people_definition.setPeopleperSpaceFloorArea(@hash[:people_per_area])
        if @hash[:radiant_fraction]
          openstudio_people_definition.setFractionRadiant(@hash[:radiant_fraction])
        else
          openstudio_people_definition.setFractionRadiant(@@schema[:definitions][:PeopleAbridged][:radiant_fraction][:default])
        end
        if @hash[:latent_fraction]
          if @hash[:latent_fraction] == 'autocalculate'
            openstudio_people_definition.autocalculateSensibleHeatFraction()
          elsif
            sensible_fraction = 1 - (@hash[:latent_fraction]).to_f
            openstudio_people_definition.setSensibleHeatFraction(sensible_fraction)
          end
        end
        openstudio_people = OpenStudio::Model::People.new(openstudio_people_definition)
        openstudio_people.setPeopleDefinition(openstudio_people_definition)
        openstudio_people.setName(@hash[:name])
        people_activity_schedule = openstudio_model.getScheduleByName(@hash[:activity_schedule])
        unless people_activity_schedule.empty?
          people_activity_schedule_object = people_activity_schedule.get
        end
        openstudio_people.setActivityLevelSchedule(people_activity_schedule_object)

        people_occupancy_schedule = openstudio_model.getScheduleByName(@hash[:occupancy_schedule])
        unless people_occupancy_schedule.empty?
          people_occupancy_schedule_object = people_occupancy_schedule.get
        end
        openstudio_people.setNumberofPeopleSchedule(people_occupancy_schedule_object)

        openstudio_people
      end

    end #PeopleAbridged
  end #EnergyModel
end #Ladybug
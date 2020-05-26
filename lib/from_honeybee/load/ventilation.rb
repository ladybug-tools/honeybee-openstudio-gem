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
  class VentilationAbridged < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
      raise "Incorrect model type '#{@type}'" unless @type == 'VentilationAbridged'
    end
  
    def defaults
      @@schema[:components][:schemas][:VentilationAbridged][:properties]
    end
  
    def find_existing_openstudio_object(openstudio_model)
      model_vent = openstudio_model.getDesignSpecificationOutdoorAirByName(@hash[:identifier])
      return model_vent.get unless model_vent.empty?
      nil
    end
  
    def to_openstudio(openstudio_model)  
      # create ventilation openstudio object and set identifier     
      os_vent = OpenStudio::Model::DesignSpecificationOutdoorAir.new(openstudio_model)
      os_vent.setName(@hash[:identifier])

      # assign air changes per hour if it exists
      if @hash[:air_changes_per_hour]
        os_vent.setOutdoorAirFlowAirChangesperHour(@hash[:air_changes_per_hour])
      else
        os_vent.setOutdoorAirFlowAirChangesperHour(defaults[:air_changes_per_hour][:default])
      end

      # assign flow per zone if it exists
      if @hash[:flow_per_zone]
        os_vent.setOutdoorAirFlowRate(@hash[:flow_per_zone])
      else
        os_vent.setOutdoorAirFlowRate(defaults[:flow_per_zone][:default])
      end

      # assign flow per person if it exists
      if @hash[:flow_per_person]
        os_vent.setOutdoorAirFlowperPerson(@hash[:flow_per_person])
      end

      # assign flow per area if it exists
      if @hash[:flow_per_area]
        os_vent.setOutdoorAirFlowperFloorArea(@hash[:flow_per_area])
      end

      # assign schedule if it exists
      if @hash[:schedule]
        vent_sch = openstudio_model.getScheduleByName(@hash[:schedule])
        unless vent_sch.empty?
          vent_sch_object = vent_sch.get
          os_vent.setOutdoorAirFlowRateFractionSchedule(vent_sch_object)
        end
      end

      os_vent
    end

  end #VentilationAbridged
end #FromHoneybee
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

require 'honeybee/load/people'

require 'to_openstudio/model_object'

module Honeybee
  class PeopleAbridged

    def find_existing_openstudio_object(openstudio_model)
      model_people = openstudio_model.getPeopleByName(@hash[:identifier])
      return model_people.get unless model_people.empty?
      nil
    end

    def to_openstudio(openstudio_model)

      # create people OpenStudio object and set identifier
      os_people_def = OpenStudio::Model::PeopleDefinition.new(openstudio_model)
      os_people = OpenStudio::Model::People.new(os_people_def)
      os_people_def.setName(@hash[:identifier])
      os_people.setName(@hash[:identifier])

      # assign people per space floor area
      os_people_def.setPeopleperSpaceFloorArea(@hash[:people_per_area])

      # assign activity schedule
      activity_sch = openstudio_model.getScheduleByName(@hash[:activity_schedule])
      unless activity_sch.empty?
        activity_sch_object = activity_sch.get
        os_people.setActivityLevelSchedule(activity_sch_object)
      end

      # assign occupancy schedule
      occupancy_sch = openstudio_model.getScheduleByName(@hash[:occupancy_schedule])
      unless occupancy_sch.empty?
        occupancy_sch_object = occupancy_sch.get
        os_people.setNumberofPeopleSchedule(occupancy_sch_object)
      end

      # assign radiant fraction if it exists
      if @hash[:radiant_fraction]
        os_people_def.setFractionRadiant(@hash[:radiant_fraction])
      else
        os_people_def.setFractionRadiant(defaults[:radiant_fraction][:default])
      end

      # assign latent fraction if it exists
      if @hash[:latent_fraction]
        if @hash[:latent_fraction].is_a? Numeric
          sensible_fraction = 1 - (@hash[:latent_fraction])
          os_people_def.setSensibleHeatFraction(sensible_fraction)
        else
          os_people_def.autocalculateSensibleHeatFraction()
        end
      end

      os_people
    end

  end #PeopleAbridged
end #Honeybee
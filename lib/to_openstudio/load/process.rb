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

require 'honeybee/load/process'

require 'to_openstudio/model_object'

module Honeybee
  class ProcessAbridged

    def find_existing_openstudio_object(openstudio_model)
      model_other_equipment = openstudio_model.getOtherEquipmentByName(@hash[:identifier])
      return model_other_equipment.get unless model_other_equipment.empty?
      nil
    end

    def to_openstudio(openstudio_model)
      # create process load and set identifier
      os_other_equip_def = OpenStudio::Model::OtherEquipmentDefinition.new(openstudio_model)
      os_other_equip = OpenStudio::Model::OtherEquipment.new(os_other_equip_def)
      os_other_equip_def.setName(@hash[:identifier])
      unless @hash[:display_name].nil?
        os_other_equip_def.setDisplayName(@hash[:display_name])
      end
      os_other_equip.setName(@hash[:identifier])

      # assign watts
      os_other_equip_def.setDesignLevel(@hash[:watts])

      # assign schedule
      other_equipment_schedule = openstudio_model.getScheduleByName(@hash[:schedule])
      unless other_equipment_schedule.empty?
        other_equipment_schedule_object = other_equipment_schedule.get
        os_other_equip.setSchedule(other_equipment_schedule_object)
      end

      # assign the fuel type
      os_other_equip.setFuelType(@hash[:fuel_type])

      # assign the end use category if it exists
      if @hash[:end_use_category]
        os_other_equip.setEndUseSubcategory(@hash[:end_use_category])
      else
        os_other_equip.setEndUseSubcategory(defaults[:end_use_category][:default])
      end

      # assign radiant fraction if it exists
      if @hash[:radiant_fraction]
        os_other_equip_def.setFractionRadiant(@hash[:radiant_fraction])
      else
        os_other_equip_def.setFractionRadiant(defaults[:radiant_fraction][:default])
      end

      # assign latent fraction if it exists
      if @hash[:latent_fraction]
        os_other_equip_def.setFractionLatent(@hash[:latent_fraction])
      else
        os_other_equip_def.setFractionLatent(defaults[:latent_fraction][:default])
      end

      # assign lost fraction if it exists
      if @hash[:lost_fraction]
        os_other_equip_def.setFractionLost(@hash[:lost_fraction])
      else
        os_other_equip_def.setFractionLost(defaults[:lost_fraction][:default])
      end

      os_other_equip
    end

  end #ProcessAbridged
end #Honeybee
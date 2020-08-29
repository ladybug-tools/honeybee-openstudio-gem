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
require 'from_honeybee/load/people'
require 'from_honeybee/load/lighting'
require 'from_honeybee/load/electric_equipment'
require 'from_honeybee/load/gas_equipment'
require 'from_honeybee/load/infiltration'
require 'from_honeybee/load/ventilation'
require 'from_honeybee/load/setpoint_thermostat'
require 'from_honeybee/load/setpoint_humidistat'

require 'openstudio'

module FromHoneybee
  class ProgramTypeAbridged < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
  
      raise "Incorrect model type '#{@type}'" unless @type == 'ProgramTypeAbridged'
    end
  
    def defaults
      @@schema[:components][:schemas][:ProgramTypeAbridged][:properties]
    end
  
    def find_existing_openstudio_object(openstudio_model)
      model_space_type = openstudio_model.getSpaceTypeByName(@hash[:identifier])
      return model_space_type.get unless model_space_type.empty?
      nil
    end
  
    def to_openstudio(openstudio_model)    
      # create openstudio space type object
      os_space_type = OpenStudio::Model::SpaceType.new(openstudio_model)
      os_space_type.setName(@hash[:identifier])

      # assign people 
      if @hash[:people]
        people = PeopleAbridged.new(@hash[:people])
        os_people = people.to_openstudio(openstudio_model)
        os_people.setSpaceType(os_space_type)
      end

      # assign lighting
      if @hash[:lighting]
        lights = LightingAbridged.new(@hash[:lighting])
        os_lights = lights.to_openstudio(openstudio_model)
        os_lights.setSpaceType(os_space_type)
      end

      # assign electric equipment
      if @hash[:electric_equipment]
        electric_equipment = ElectricEquipmentAbridged.new(@hash[:electric_equipment])
        os_electric_equipment = electric_equipment.to_openstudio(openstudio_model)
        os_electric_equipment.setSpaceType(os_space_type)
      end

      # assign gas equipment
      if @hash[:gas_equipment]
        gas_equipment = GasEquipmentAbridged.new(@hash[:gas_equipment])
        os_gas_equipment = gas_equipment.to_openstudio(openstudio_model)
        os_gas_equipment.setSpaceType(os_space_type)
      end

      # assign infiltration
      if @hash[:infiltration] && $use_simple_vent  # only use infiltration with simple ventilation
        infiltration = InfiltrationAbridged.new(@hash[:infiltration])
        os_infiltration = infiltration.to_openstudio(openstudio_model)
        os_infiltration.setSpaceType(os_space_type)
      end

      # assign ventilation
      if @hash[:ventilation]
        ventilation = VentilationAbridged.new(@hash[:ventilation])
        os_ventilation = ventilation.to_openstudio(openstudio_model)
        os_space_type.setDesignSpecificationOutdoorAir(os_ventilation)
      end

      # add setpoints from to a global hash that will be used to assign them to rooms
      if @hash[:setpoint]
        $programtype_setpoint_hash[@hash[:identifier]] = @hash[:setpoint]
      end

      os_space_type
    end

  end #ProgramTypeAbridged 
end #FromHoneybee




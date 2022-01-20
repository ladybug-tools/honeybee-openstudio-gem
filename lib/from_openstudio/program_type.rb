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

require 'honeybee/program_type'
require 'to_openstudio/model_object'

module Honeybee
    class ProgramTypeAbridged < ModelObject

        def self.from_programtype(programtype)
            # create an empty hash
            hash = {}
            hash[:type] = 'ProgramTypeAbridged'
            # set hash values from OpenStudio Object
            hash[:identifier] = clean_name(programtype.nameString)
            unless programtype.displayName.empty?
                hash[:display_name] = (programtype.displayName.get).force_encoding("UTF-8")
            end
            unless programtype.people.empty?
                programtype.people.each do |people|
                    people_def = people.peopleDefinition
                    # Only translate if people per floor area is specified
                    # Check if schedule exists and is of the correct type
                    if !people_def.peopleperSpaceFloorArea.empty? && !people.numberofPeopleSchedule.empty?
                        sch = people.numberofPeopleSchedule.get
                        if sch.to_ScheduleFixedInterval.is_initialized or sch.to_ScheduleRuleset.is_initialized
                            hash[:people] = Honeybee::PeopleAbridged.from_load(people)
                            break
                        end
                    end
                end
            end
            unless programtype.lights.empty?
                programtype.lights.each do |light|
                    light_def = light.lightsDefinition
                    # Only translate if watts per floor area is specified
                    # Check if schedule exists and is of the correct type
                    if !light_def.wattsperSpaceFloorArea.empty? && !light.schedule.empty?
                        sch = light.schedule.get
                        if sch.to_ScheduleFixedInterval.is_initialized or sch.to_ScheduleRuleset.is_initialized
                            hash[:lighting] = Honeybee::LightingAbridged.from_load(light)
                            break
                        end
                    end
                end
            end
            unless programtype.electricEquipment.empty?
                programtype.electricEquipment.each do |electric_eq|
                    electric_eq_def = electric_eq.electricEquipmentDefinition
                    # Only translate if watts per floor area is specified
                    # Check if schedule exists and is of the correct type
                    if !electric_eq_def.wattsperSpaceFloorArea.empty? && !electric_eq.schedule.empty?
                        sch = electric_eq.schedule.get
                        if sch.to_ScheduleFixedInterval.is_initialized or sch.to_ScheduleRuleset.is_initialized
                            hash[:electric_equipment] = Honeybee::ElectricEquipmentAbridged.from_load(electric_eq)
                            break
                        end
                    end
                end
            end
            unless programtype.gasEquipment.empty?
                programtype.gasEquipment.each do |gas_eq|
                    gas_eq_def = gas_eq.gasEquipmentDefinition
                    # Only translate if watts per floor area is specified
                    # Check if schedule exists and is of the correct type
                    if !gas_eq_def.wattsperSpaceFloorArea.empty? && !gas_eq.schedule.empty?
                        sch = gas_eq.schedule.get
                        if sch.to_ScheduleFixedInterval.is_initialized or sch.to_ScheduleRuleset.is_initialized
                            hash[:gas_equipment] = Honeybee::GasEquipmentAbridged.from_load(gas_eq)
                            break
                        end
                    end
                end
            end
            unless programtype.spaceInfiltrationDesignFlowRates.empty?
                programtype.spaceInfiltrationDesignFlowRates.each do |infiltration|
                    # Only translate if flow per exterior area is specified
                    # Check if schedule exists and is of the correct type
                    if !infiltration.flowperExteriorSurfaceArea.empty? && !infiltration.schedule.empty?
                        sch = infiltration.schedule.get
                        if sch.to_ScheduleFixedInterval.is_initialized or sch.to_ScheduleRuleset.is_initialized
                            hash[:infiltration] = Honeybee::InfiltrationAbridged.from_load(infiltration)
                            break
                        end
                    end
                end
            end
            unless programtype.designSpecificationOutdoorAir.empty?
                hash[:ventilation] = Honeybee::VentilationAbridged.from_load(programtype.designSpecificationOutdoorAir.get)
            end

            hash
        end

    end # ProgramTypeAbridged
end # Honeybee
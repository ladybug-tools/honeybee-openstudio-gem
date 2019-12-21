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

require "#{File.dirname(__FILE__)}/version"
require "#{File.dirname(__FILE__)}/extension"
require "#{File.dirname(__FILE__)}/extension_simulation_parameter"
require "#{File.dirname(__FILE__)}/aperture"
require "#{File.dirname(__FILE__)}/energy_material"
require "#{File.dirname(__FILE__)}/energy_material_no_mass"
require "#{File.dirname(__FILE__)}/energy_window_material_gas"
require "#{File.dirname(__FILE__)}/energy_window_material_gas_mixture"
require "#{File.dirname(__FILE__)}/energy_window_material_gas_custom"
require "#{File.dirname(__FILE__)}/energy_window_material_blind"
require "#{File.dirname(__FILE__)}/energy_window_material_glazing"
require "#{File.dirname(__FILE__)}/energy_window_material_shade"
require "#{File.dirname(__FILE__)}/energy_window_material_simpleglazsys"
require "#{File.dirname(__FILE__)}/opaque_construction_abridged"
require "#{File.dirname(__FILE__)}/window_construction_abridged"
require "#{File.dirname(__FILE__)}/shade_construction"
require "#{File.dirname(__FILE__)}/construction_set"
require "#{File.dirname(__FILE__)}/face"
require "#{File.dirname(__FILE__)}/model"
require "#{File.dirname(__FILE__)}/model_object"
require "#{File.dirname(__FILE__)}/room"
require "#{File.dirname(__FILE__)}/aperture"
require "#{File.dirname(__FILE__)}/door"
require "#{File.dirname(__FILE__)}/shade"
require "#{File.dirname(__FILE__)}/schedule_type_limit"
require "#{File.dirname(__FILE__)}/schedule_fixed_interval_abridged"
require "#{File.dirname(__FILE__)}/schedule_ruleset_abridged"
require "#{File.dirname(__FILE__)}/space_type"
require "#{File.dirname(__FILE__)}/people_abridged"
require "#{File.dirname(__FILE__)}/lighting_abridged"
require "#{File.dirname(__FILE__)}/electric_equipment_abridged"
require "#{File.dirname(__FILE__)}/gas_equipment_abridged"
require "#{File.dirname(__FILE__)}/infiltration_abridged"
require "#{File.dirname(__FILE__)}/ventilation_abridged"
require "#{File.dirname(__FILE__)}/setpoint_thermostat"
require "#{File.dirname(__FILE__)}/setpoint_humidistat"
require "#{File.dirname(__FILE__)}/ideal_air_system"
require "#{File.dirname(__FILE__)}/simulation_parameter"
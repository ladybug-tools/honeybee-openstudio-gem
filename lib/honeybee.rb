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

# import the core objects from which everything inherits
require 'honeybee/extension'
require 'honeybee/model_object'

# import the compound objects that house the other objects
require 'honeybee/model'
require 'honeybee/construction_set'
require 'honeybee/program_type'

# import the geometry objects
require 'honeybee/geometry/shade'
require 'honeybee/geometry/door'
require 'honeybee/geometry/aperture'
require 'honeybee/geometry/face'
require 'honeybee/geometry/room'

# import the HVAC objects
require 'honeybee/hvac/ideal_air'
require 'honeybee/hvac/template'

# import the construction objects
require 'honeybee/construction/opaque'
require 'honeybee/construction/window'
require 'honeybee/construction/windowshade'
require 'honeybee/construction/dynamic'
require 'honeybee/construction/shade'
require 'honeybee/construction/air'

# import the material objects
require 'honeybee/material/opaque'
require 'honeybee/material/opaque_no_mass'
require 'honeybee/material/window_gas'
require 'honeybee/material/window_gas_mixture'
require 'honeybee/material/window_gas_custom'
require 'honeybee/material/window_blind'
require 'honeybee/material/window_glazing'
require 'honeybee/material/window_shade'
require 'honeybee/material/window_simpleglazsys'

# import the load objects
require 'honeybee/load/people'
require 'honeybee/load/lighting'
require 'honeybee/load/electric_equipment'
require 'honeybee/load/gas_equipment'
require 'honeybee/load/service_hot_water'
require 'honeybee/load/infiltration'
require 'honeybee/load/ventilation'
require 'honeybee/load/setpoint_thermostat'
require 'honeybee/load/setpoint_humidistat'
require 'honeybee/load/daylight'

# import the schedule objects
require 'honeybee/schedule/type_limit'
require 'honeybee/schedule/fixed_interval'
require 'honeybee/schedule/ruleset'

# import the ventilation and internal mass objects
require 'honeybee/ventcool/control'
require 'honeybee/ventcool/opening'
require 'honeybee/ventcool/simulation'
require 'honeybee/internalmass'

# import the simulation objects
require 'honeybee/simulation/design_day'
require 'honeybee/simulation/parameter_model'
require 'honeybee/simulation/simulation_output'

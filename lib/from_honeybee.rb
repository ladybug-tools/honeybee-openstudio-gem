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
require 'from_honeybee/extension'
require 'from_honeybee/model_object'

# import the compound objects that house the other objects
require 'from_honeybee/model'
require 'from_honeybee/construction_set'
require 'from_honeybee/program_type'

# import the geometry objects
require 'from_honeybee/geometry/shade'
require 'from_honeybee/geometry/door'
require 'from_honeybee/geometry/aperture'
require 'from_honeybee/geometry/face'
require 'from_honeybee/geometry/room'

# import the HVAC objects
require 'from_honeybee/hvac/ideal_air'

# import the construction objects
require 'from_honeybee/construction/opaque'
require 'from_honeybee/construction/window'
require 'from_honeybee/construction/windowshade'
require 'from_honeybee/construction/shade'
require 'from_honeybee/construction/air'

# import the material objects
require 'from_honeybee/material/opaque'
require 'from_honeybee/material/opaque_no_mass'
require 'from_honeybee/material/window_gas'
require 'from_honeybee/material/window_gas_mixture'
require 'from_honeybee/material/window_gas_custom'
require 'from_honeybee/material/window_blind'
require 'from_honeybee/material/window_glazing'
require 'from_honeybee/material/window_shade'
require 'from_honeybee/material/window_simpleglazsys'

# import the load objects
require 'from_honeybee/load/people'
require 'from_honeybee/load/lighting'
require 'from_honeybee/load/electric_equipment'
require 'from_honeybee/load/gas_equipment'
require 'from_honeybee/load/infiltration'
require 'from_honeybee/load/ventilation'
require 'from_honeybee/load/setpoint_thermostat'
require 'from_honeybee/load/setpoint_humidistat'

# import the schedule objects
require 'from_honeybee/schedule/type_limit'
require 'from_honeybee/schedule/fixed_interval'
require 'from_honeybee/schedule/ruleset'

# import the simulation objects
require 'from_honeybee/simulation/extension'
require 'from_honeybee/simulation/parameter'

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

# import the honeybee objects which we will extend
require 'honeybee'

# extend the compound objects that house the other objects
require 'to_openstudio/model'
require 'to_openstudio/model_object'
require 'to_openstudio/construction_set'
require 'to_openstudio/program_type'

# extend the geometry objects
require 'to_openstudio/geometry/shade'
require 'to_openstudio/geometry/door'
require 'to_openstudio/geometry/aperture'
require 'to_openstudio/geometry/face'
require 'to_openstudio/geometry/room'

# extend the HVAC objects
require 'to_openstudio/hvac/ideal_air'
require 'to_openstudio/hvac/template'

# extend the construction objects
require 'to_openstudio/construction/opaque'
require 'to_openstudio/construction/window'
require 'to_openstudio/construction/windowshade'
require 'to_openstudio/construction/dynamic'
require 'to_openstudio/construction/shade'
require 'to_openstudio/construction/air'

# extend the material objects
require 'to_openstudio/material/opaque'
require 'to_openstudio/material/opaque_no_mass'
require 'to_openstudio/material/window_gas'
require 'to_openstudio/material/window_gas_mixture'
require 'to_openstudio/material/window_gas_custom'
require 'to_openstudio/material/window_blind'
require 'to_openstudio/material/window_glazing'
require 'to_openstudio/material/window_shade'
require 'to_openstudio/material/window_simpleglazsys'

# extend the load objects
require 'to_openstudio/load/people'
require 'to_openstudio/load/lighting'
require 'to_openstudio/load/electric_equipment'
require 'to_openstudio/load/gas_equipment'
require 'to_openstudio/load/service_hot_water'
require 'to_openstudio/load/infiltration'
require 'to_openstudio/load/ventilation'
require 'to_openstudio/load/setpoint_thermostat'
require 'to_openstudio/load/setpoint_humidistat'
require 'to_openstudio/load/daylight'

# extend the schedule objects
require 'to_openstudio/schedule/type_limit'
require 'to_openstudio/schedule/fixed_interval'
require 'to_openstudio/schedule/ruleset'

# import the ventilation and internal mass objects
require 'to_openstudio/ventcool/control'
require 'to_openstudio/ventcool/opening'
require 'to_openstudio/ventcool/simulation'
require 'to_openstudio/internalmass'

# extend the simulation objects
require 'to_openstudio/simulation/design_day'
require 'to_openstudio/simulation/parameter_model'
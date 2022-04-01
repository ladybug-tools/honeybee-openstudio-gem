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
require 'from_openstudio/model'
require 'from_openstudio/model_object'
require 'from_openstudio/construction_set'

# extend the geometry objects
require 'from_openstudio/geometry/aperture'
require 'from_openstudio/geometry/door'
require 'from_openstudio/geometry/face'
require 'from_openstudio/geometry/room'
require 'from_openstudio/geometry/shade'

# extend the construction objects
require 'from_openstudio/construction/opaque'
require 'from_openstudio/construction/window'
require 'from_openstudio/construction/shade'
require 'from_openstudio/construction/air'

# import the material objects
require 'from_openstudio/material/opaque'
require 'from_openstudio/material/opaque_no_mass'
require 'from_openstudio/material/vegetation'
require 'from_openstudio/material/window_gas'
require 'from_openstudio/material/window_gas_mixture'
require 'from_openstudio/material/window_gas_custom'
require 'from_openstudio/material/window_blind'
require 'from_openstudio/material/window_glazing'
require 'from_openstudio/material/window_simpleglazsys'

# extend the simulation objects
require 'from_openstudio/simulation/design_day'
require 'from_openstudio/simulation/parameter_model'
require 'from_openstudio/simulation/simulation_output'

# extend the schedule objects
require 'from_openstudio/schedule/type_limit'
require 'from_openstudio/schedule/ruleset'
require 'from_openstudio/schedule/fixed_interval'

# extend the load objects
require 'from_openstudio/load/electric_equipment'
require 'from_openstudio/load/people'
require 'from_openstudio/load/gas_equipment'
require 'from_openstudio/load/lighting'
require 'from_openstudio/load/infiltration'
require 'from_openstudio/load/ventilation'
require 'from_openstudio/load/daylight'
require 'from_openstudio/load/process'
require 'from_openstudio/load/service_hot_water'

# extend the program type objects
require 'from_openstudio/program_type'

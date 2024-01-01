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

require 'honeybee/generator/pv'

require 'to_openstudio/model_object'

module Honeybee
  class PVProperties

    def to_openstudio(openstudio_model, parent)
      # calculate the DC system size from the efficiency and the parent area
      rated_watts = defaults[:rated_efficiency][:default] * 1000
      if @hash[:rated_efficiency]
        rated_watts = @hash[:rated_efficiency]  * 1000
      end
      active_fraction = defaults[:active_area_fraction][:default]
      if @hash[:active_area_fraction]
        active_fraction = @hash[:active_area_fraction]
      end
      sys_cap = parent.netArea * active_fraction * rated_watts
      sys_cap = sys_cap.round

      # create the PVWatts generator and set identifier
      os_gen = OpenStudio::Model::GeneratorPVWatts.new(openstudio_model, parent, sys_cap)
      os_gen.setName(@hash[:identifier] + '..' + parent.name.get)

      # assign the module type
      if @hash[:module_type]
        os_gen.setModuleType(@hash[:module_type])
      else
        os_gen.setModuleType(defaults[:module_type][:default])
      end

      # assign the mounting type
      if @hash[:mounting_type]
        os_gen.setArrayType(@hash[:mounting_type])
      else
        os_gen.setArrayType(defaults[:mounting_type][:default])
      end

      # assign the system loss fraction
      if @hash[:system_loss_fraction]
        os_gen.setSystemLosses(@hash[:system_loss_fraction])
      else
        os_gen.setSystemLosses(defaults[:system_loss_fraction][:default])
      end

      # assign the tracking ground coverage ratio
      if @hash[:tracking_ground_coverage_ratio]
        os_gen.setGroundCoverageRatio(@hash[:tracking_ground_coverage_ratio])
      end

      os_gen
    end

  end #PVProperties
end #Honeybee

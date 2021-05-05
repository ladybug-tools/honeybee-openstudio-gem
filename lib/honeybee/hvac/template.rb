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

require 'honeybee/model_object'

module Honeybee
  class TemplateHVAC < ModelObject
    attr_reader :errors, :warnings

    @@all_air_types = ['VAV', 'PVAV', 'PSZ', 'PTAC', 'ForcedAirFurnace']
    @@doas_types = ['FCUwithDOASAbridged', 'WSHPwithDOASAbridged', 'VRFwithDOASAbridged']
    @@heat_cool_types = ['FCU', 'WSHP', 'VRF', 'Baseboard',  'EvaporativeCooler',
                         'Residential', 'WindowAC', 'GasUnitHeater']
    @@types = @@all_air_types + @@doas_types + @@heat_cool_types

    def allowable_types
      @@types
    end

    def self.types
      # array of all supported template HVAC systems
      @@types
    end

    def self.all_air_types
      # array of the All Air HVAC types
      @@all_air_types
    end

    def self.doas_types
      # array of the DOAS HVAC types
      @@doas_types
    end

    def self.heat_cool_types
      # array of the system types providing heating and cooling only
      @@heat_cool_types
    end

    def defaults(system_type)
      @@schema[:components][:schemas][system_type.to_sym][:properties]
    end

  end #TemplateHVAC
end #Honeybee

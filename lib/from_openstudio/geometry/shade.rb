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

require 'honeybee/geometry/shade'

require 'to_openstudio/model_object'

module Honeybee
  class Shade

    def self.from_shading_surface(shading_surface, site_transformation)
      hash = {}
      hash[:type] = 'Shade'
      hash[:identifier] = clean_identifier(shading_surface.nameString)
      hash[:display_name] = clean_display_name(shading_surface.nameString)
      hash[:user_data] = {handle: shading_surface.handle.to_s}
      hash[:properties] = properties_from_shading_surface(shading_surface)
      hash[:geometry] = geometry_from_shading_surface(shading_surface, site_transformation)

      hash
    end

    def self.properties_from_shading_surface(shading_surface)
      hash = {}
      hash[:type] = 'ShadePropertiesAbridged'
      hash[:energy] = energy_properties_from_shading_surface(shading_surface)
      hash
    end

    def self.energy_properties_from_shading_surface(shading_surface)
      hash = {}
      hash[:type] = 'ShadeEnergyPropertiesAbridged'

      unless shading_surface.isConstructionDefaulted
        construction = shading_surface.construction
        if !construction.empty?
          const_name = construction.get.nameString
          hash[:construction] = const_name
          unless $shade_constructions.has_key?(const_name)
            const_obj = construction.get
            const = const_obj.to_LayeredConstruction.get
            $shade_constructions[const_name] = const
          end
        end
      end

      transmittance_schedule = shading_surface.transmittanceSchedule
      if !transmittance_schedule.empty?
        hash[:transmittance_schedule] = transmittance_schedule.get.nameString
      end

      hash
    end

    def self.geometry_from_shading_surface(shading_surface, site_transformation)
      result = {}
      result[:type] = 'Face3D'
      result[:boundary] = []
      vertices = site_transformation * shading_surface.vertices
      vertices.each do |v|
        result[:boundary] << [v.x, v.y, v.z]
      end
      result
    end

  end #Shade
end #Honeybee

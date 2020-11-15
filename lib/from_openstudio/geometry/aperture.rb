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

require 'honeybee/geometry/aperture'

require 'to_openstudio/model_object'

module Honeybee
  class Aperture < ModelObject

    def self.from_sub_surface(sub_surface, site_transformation)
      hash = {}
      hash[:type] = 'Aperture'
      hash[:identifier] = sub_surface.nameString
      hash[:display_name] = sub_surface.nameString
      hash[:user_data] = {handle: sub_surface.handle.to_s}
      hash[:properties] = properties_from_sub_surface(sub_surface)
      hash[:geometry] = geometry_from_sub_surface(sub_surface, site_transformation)

      sub_surface_type = sub_surface.subSurfaceType
      hash[:is_operable] = (sub_surface_type == 'OperableWindow')

      hash
    end

    def self.properties_from_sub_surface(sub_surface)
      hash = {}
      hash[:type] = 'AperturePropertiesAbridged'
      hash[:energy] = energy_properties_from_sub_surface(sub_surface)
      hash
    end

    def self.energy_properties_from_sub_surface(sub_surface)
      hash = {}
      hash[:type] = 'ApertureFaceEnergyPropertiesAbridged'
      hash
    end

    def self.geometry_from_sub_surface(sub_surface, site_transformation)
      result = {}
      result[:type] = 'Face3D'
      result[:boundary] = []
      vertices = site_transformation * sub_surface.vertices
      vertices.each do |v|
        result[:boundary] << [v.x, v.y, v.z]
      end
      result
    end

  end # Aperture
end # Honeybee

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
  class Face < ModelObject

    def self.from_surface(surface, site_transformation)
      hash = {}
      hash[:type] = 'Face'
      hash[:identifier] = surface.nameString
      hash[:display_name] = surface.nameString
      hash[:properties] = self.properties_from_surface(surface)
      hash[:geometry] = self.geometry_from_surface(surface, site_transformation)
      hash[:face_type] = self.face_type_from_surface(surface)
      hash[:boundary_condition] = self.boundary_condition_from_surface(surface)
      hash
    end

    def self.properties_from_surface(surface)
      hash = {}
      hash[:type] = 'FacePropertiesAbridged'
      hash[:energy] = self.energy_properties_from_surface(surface)
      hash
    end

    def self.energy_properties_from_surface(surface)
      hash = {}
      hash[:type] = 'FaceEnergyPropertiesAbridged'
      hash
    end

    def self.geometry_from_surface(surface, site_transformation)
      result = {}
      result[:type] = 'Face3D'
      result[:boundary] = []
      vertices = site_transformation * surface.vertices
      vertices.each do |v|
        result[:boundary] << [v.x, v.y, v.z]
      end
      result
    end

    def self.face_type_from_surface(surface)
      # "Wall", "Floor", "RoofCeiling", "AirBoundary"
      surface.surfaceType
    end

    def self.boundary_condition_from_surface(surface)
      {}
    end

  end #Shade
end #Honeybee

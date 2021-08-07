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
  class Room < ModelObject

    def self.from_space(space)
      hash = {}
      hash[:type] = 'Room'
      hash[:identifier] = clean_identifier(space.nameString)
      hash[:display_name] = clean_display_name(space.nameString)
      hash[:user_data] = {space: space.handle.to_s}
      hash[:properties] = properties_from_space(space)

      site_transformation = space.siteTransformation
      hash[:faces] = faces_from_space(space, site_transformation)

      indoor_shades = indoor_shades_from_space(space)
      hash[:indoor_shades] = indoor_shades if !indoor_shades.empty?

      outdoor_shades = outdoor_shades_from_space(space)
      hash[:outdoor_shades] = outdoor_shades if !outdoor_shades.empty?

      multipler = multiplier_from_space(space)
      hash[:multipler] = multipler if multipler

      story = story_from_space(space)
      hash[:story] = story if story

      hash
    end

    def self.properties_from_space(space)
      hash = {}
      hash[:type] = 'RoomPropertiesAbridged'
      hash[:energy] = self.energy_properties_from_space(space)
      hash
    end

    def self.energy_properties_from_space(space)
      hash = {}
      hash[:type] = 'RoomEnergyPropertiesAbridged'
      hash
    end

    def self.faces_from_space(space, site_transformation)
      result = []
      space.surfaces.each do |surface|
        result << Face.from_surface(surface, site_transformation)
      end
      result
    end

    def self.indoor_shades_from_space(space)
      []
    end

    def self.outdoor_shades_from_space(space)
      result = []
      space.shadingSurfaceGroups.each do |shading_surface_group|
        # skip if attached to a surface or sub_surface
        if !shading_surface_group.shadedSurface.empty? || !shading_surface_group.shadedSubSurface.empty?
          next
        end

        site_transformation = shading_surface_group.siteTransformation
        shading_surface_group.shadingSurfaces.each do |shading_surface|
          result << Shade.from_shading_surface(shading_surface, site_transformation)
        end
      end
      result
    end

    def self.multiplier_from_space(space)
      multiplier = space.multiplier
      if multiplier != 1
        return multiplier
      end
      nil
    end

    def self.story_from_space(space)
      story = space.buildingStory
      if !story.empty?
        return story.get.nameString
      end
      nil
    end

  end # Aperture
end # Honeybee

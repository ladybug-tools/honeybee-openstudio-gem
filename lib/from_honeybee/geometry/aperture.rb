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

require 'from_honeybee/model_object'

require 'openstudio'

module FromHoneybee
  class Aperture < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash)
      super(hash)
      raise "Incorrect model type '#{@type}'" unless @type == 'Aperture'
    end

    def defaults
      @@schema[:components][:schemas][:ApertureEnergyPropertiesAbridged][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getSubSurfaceByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create the OpenStudio aperture object
      os_vertices = OpenStudio::Point3dVector.new
      @hash[:geometry][:boundary].each do |vertex|
        os_vertices << OpenStudio::Point3d.new(vertex[0], vertex[1], vertex[2])
      end
      reordered_vertices = OpenStudio.reorderULC(os_vertices)
      
      # triangulate subsurface if neccesary
      triangulated = false
      final_vertices_list = []
      matching_os_subsurfaces = []
      matching_os_subsurface_indices = []
      if reordered_vertices.size > 4
      
        # if this apeture has a matched apeture, see if the other one has already been created
        # the matched apeture should have been converted to multiple subsurfaces
        if @hash[:boundary_condition][:type] == 'Surface'
          adj_srf_identifier = @hash[:boundary_condition][:boundary_condition_objects][0]
          regex = Regexp.new("#{adj_srf_identifier}\.\.(\\d+)")
          openstudio_model.getSubSurfaces.each do |subsurface|
            if md = regex.match(subsurface.nameString)
              final_vertices_list << OpenStudio.reorderULC(OpenStudio::reverse(subsurface.vertices))
              matching_os_subsurfaces << subsurface
              matching_os_subsurface_indices << md[1]
            end
          end
        end
        
        # if other apeture is not already created, do the triangulation
        if final_vertices_list.empty?
          
          # transform to face coordinates
          t = OpenStudio::Transformation::alignFace(reordered_vertices)
          tInv = t.inverse
          face_vertices = OpenStudio::reverse(tInv*reordered_vertices)
          
          # no holes in the subsurface
          holes = OpenStudio::Point3dVectorVector.new
          
          # triangulate surface
          triangles = OpenStudio::computeTriangulation(face_vertices, holes)
          if triangles.empty?
            raise "Failed to triangulate aperture #{@hash[:identifier]} with #{reordered_vertices.size} vertices"
          end
          
          # create new list of surfaces
          triangles.each do |vertices|
            final_vertices_list << OpenStudio.reorderULC(OpenStudio::reverse(t*vertices))
          end
          
          triangulated = true
          
        end
        
      else
        # reordered_vertices are good as is
        final_vertices_list << reordered_vertices
      end

      result = []
      final_vertices_list.each_with_index do |reordered_vertices, index|
        os_subsurface = OpenStudio::Model::SubSurface.new(reordered_vertices, openstudio_model)
        
        if !matching_os_subsurfaces.empty?
          os_subsurface.setName(@hash[:identifier] + "..#{matching_os_subsurface_indices[index]}")
        elsif triangulated
          os_subsurface.setName(@hash[:identifier] + "..#{index}")
        else
          os_subsurface.setName(@hash[:identifier])
        end
        
        # assign the construction if it exists
        if @hash[:properties][:energy][:construction]
          construction_identifier = @hash[:properties][:energy][:construction]
          construction = openstudio_model.getConstructionByName(construction_identifier)
          unless construction.empty?
            os_construction = construction.get
            os_subsurface.setConstruction(os_construction)
          end
        end
        
        # assign the boundary condition object if it's a Surface
        if @hash[:boundary_condition][:type] == 'Surface'
          if !matching_os_subsurfaces.empty?
            # we already have the match because this was created from the matching_os_subsurfaces
            # setAdjacentSubSurface will fail at this point because sub surface is not assigned to surface yet, store data for later
            adj_srf_identifier = matching_os_subsurfaces[index].nameString
            os_subsurface.additionalProperties.setFeature("AdjacentSubSurfaceName", adj_srf_identifier)
          elsif triangulated
            # other subsurfaces haven't been created yet, no-op
          else
            # get adjacent sub surface by identifier from openstudio model
            # setAdjacentSubSurface will fail at this point because sub surface is not assigned to surface yet, store data for later
            adj_srf_identifier = @hash[:boundary_condition][:boundary_condition_objects][0]
            os_subsurface.additionalProperties.setFeature("AdjacentSubSurfaceName", adj_srf_identifier)
          end
        end

        # assign the operable property
        if @hash[:is_operable] == false
          os_subsurface.setSubSurfaceType('FixedWindow')
        else 
          os_subsurface.setSubSurfaceType('OperableWindow')
        end
        
        result << os_subsurface
      end
      
      return result
    end
  end # Aperture
end # FromHoneybee

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

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getSurfaceByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # get the vertices from the face
      if @hash[:geometry][:vertices].nil?
        hb_verts = @hash[:geometry][:boundary]
      else
        hb_verts = @hash[:geometry][:vertices]
      end

      # create the openstudio shading surface
      os_vertices = OpenStudio::Point3dVector.new
      hb_verts.each do |vertex|
        os_vertices << OpenStudio::Point3d.new(vertex[0], vertex[1], vertex[2])
      end

      os_shading_surface = OpenStudio::Model::ShadingSurface.new(os_vertices, openstudio_model)
      os_shading_surface.setName(@hash[:identifier])
      unless @hash[:display_name].nil?
        os_shading_surface.setDisplayName(@hash[:display_name])
      end

      if @hash[:properties].key?(:energy)
        # assign the construction if it exists
        if @hash[:properties][:energy][:construction]
          construction_identifier = @hash[:properties][:energy][:construction]
          construction = openstudio_model.getConstructionByName(construction_identifier)
          unless construction.empty?
            os_construction = construction.get
            os_shading_surface.setConstruction(os_construction)
          end
        end

        # assign the transmittance schedule if it exists
        if @hash[:properties][:energy][:transmittance_schedule]
          schedule_identifier = @hash[:properties][:energy][:transmittance_schedule]
          schedule = openstudio_model.getScheduleByName(schedule_identifier)
          unless schedule.empty?
            os_schedule = schedule.get
            os_shading_surface.setTransmittanceSchedule(os_schedule)
          end
        end

        # create PV objects if there are properties
        if @hash[:properties][:energy][:pv_properties]
          gen_obj = PVProperties.new(@hash[:properties][:energy][:pv_properties])
          os_gen_obj = gen_obj.to_openstudio(openstudio_model, os_shading_surface)
          $generators << os_gen_obj
        end
      end

      os_shading_surface
    end
  end #Shade
end #Honeybee

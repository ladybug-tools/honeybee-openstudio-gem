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
require 'from_honeybee/construction/window'

require 'openstudio'

module FromHoneybee
  class WindowConstructionShadeAbridged < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
      @construction = nil
      @shade_construction = nil
      @shade_location = nil
      @shade_material = nil
      @control_type = nil
      @setpoint = nil
      @schedule = nil
    end

    def defaults
      @@schema[:components][:schemas][:WindowConstructionShadeAbridged][:properties]
    end

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getConstructionByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # write the shaded and unsaded versions of the construciton into the model
      # reverse the shaded and unshaded identifiers so unshaded one is assigned to apertures
      unshd_id = @hash[:identifier]
      shd_id = @hash[:window_construction][:identifier]
      @hash[:window_construction][:identifier] = unshd_id
      @hash[:identifier] = shd_id

      # create the unshaded construction
      unshd_constr_obj = WindowConstructionAbridged.new(@hash[:window_construction])
      @construction = unshd_constr_obj.to_openstudio(openstudio_model)

      # create the shaded construction
      @shade_construction = OpenStudio::Model::Construction.new(openstudio_model)
      @shade_construction.setName(shd_id)

      # create the layers of the unshaded construction into which we will insert the shade
      os_materials = []
      @hash[:window_construction][:layers].each do |layer|
        material_identifier = layer
        material = openstudio_model.getMaterialByName(material_identifier)
        unless material.empty?
          os_material = material.get
          os_materials << os_material
        end
      end

      # figure out where to insert the shade material and insert it
      if @hash[:shade_location]
        @shade_location = @hash[:shade_location]
      else
        @shade_location = defaults[:shade_location][:default]
      end

      # insert the shade material
      shd_mat_name = openstudio_model.getMaterialByName(@hash[:shade_material])
      unless shd_mat_name.empty?
        @shade_material = shd_mat_name.get
        obj_type = @shade_material.iddObject.name
      end
      unless @shade_material.nil?
        if obj_type == 'OS:WindowMaterial:StandardGlazing'
          if @shade_location == 'Interior'
              os_materials[-1] = @shade_material
          elsif @shade_location == 'Exterior' | os_materials.length < 2
              os_materials[0] = @shade_material
          else  # middle glass pane
              os_materials[-3] = @shade_material
          end
        else
          if @shade_location == 'Interior'
              os_materials << @shade_material
          elsif @shade_location == 'Exterior'
              os_materials.unshift(@shade_material)
          else  # between glass shade/blind
            split_gap = split_gas_gap(openstudio_model, os_materials[-2], @shade_material)
            os_materials[-2] = split_gap
            os_materials.insert(-2, @shade_material)
            os_materials.insert(-2, split_gap)
          end
        end
      end

      # assign the layers to the shaded construction
      os_materials_vec = OpenStudio::Model::MaterialVector.new
      os_materials.each do |mat|
        os_materials_vec << mat
      end
      @shade_construction.setLayers(os_materials)

      # set defaults for control type, setpoint, and schedule
      if @hash[:control_type]
        @control_type = @hash[:control_type]
      else
        @control_type = defaults[:control_type][:default]
      end

      if @hash[:setpoint]
        @setpoint = @hash[:setpoint]
      else
        @setpoint = defaults[:setpoint][:default]
      end

      unless @hash[:schedule].nil?
        schedule_ref = openstudio_model.getScheduleByName(@hash[:schedule])
        unless schedule_ref.empty?
            @schedule = schedule_ref.get
            if @control_type == 'AlwaysOn'
                @control_type = 'OnIfScheduleAllows'
            end
        end
      end

      @shade_construction
    end

    def to_openstudio_shading_control(openstudio_model)
      # add a WindowShadingControl object to a model for a given aperture and room
      os_shade_control = OpenStudio::Model::ShadingControl.new(@shade_construction)

      # figure out the shading type
      unless @shade_material.nil?
        obj_type = @shade_material.iddObject.name
      end
      if obj_type == 'OS:WindowMaterial:StandardGlazing'
        shd_type = 'SwitchableGlazing'
      elsif obj_type == 'OS:WindowMaterial:Blind'
        if @shade_location == 'Between'
          shd_type = 'BetweenGlassBlind'
        else
          shd_type = @shade_location + 'Blind'
        end
      else
        if @shade_location == 'Between'
          shd_type = 'BetweenGlassShade'
        else
          shd_type = @shade_location + 'Shade'
        end
      end
      os_shade_control.setShadingType(shd_type)

      # set the shade control type and schedule
      os_shade_control.setShadingControlType(@control_type)
      unless @setpoint.nil?
        os_shade_control.setSetpoint(@setpoint)
      end
      unless @schedule.nil?
        os_shade_control.setSchedule(@schedule)
      end

      os_shade_control
    end

    def split_gas_gap(openstudio_model, original_gap, shade_material)
        # split a gas gap material in two when it is interrupeted by a shade/blind
        if shade_material.is_a? OpenStudio::Model::Blind
          shd_thick = 0
        else
          shd_thick = shade_material.thickness
        end
        gap_thick = (original_gap.thickness - shd_thick) / 2
        gap_obj = $gas_gap_hash[original_gap.name.get]
        new_gap = gap_obj.to_openstudio(openstudio_model)
        new_gap.setName(original_gap.name.get + gap_thick.to_s)
        new_gap.setThickness(gap_thick)
        new_gap
    end

  end #WindowConstructionShadeAbridged
end #FromHoneybee

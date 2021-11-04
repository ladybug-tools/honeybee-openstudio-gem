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

require 'honeybee/construction/window'

require 'to_openstudio/model_object'

module Honeybee
  class WindowConstructionAbridged

    def find_existing_openstudio_object(openstudio_model)
      object = openstudio_model.getConstructionByName(@hash[:identifier])
      return object.get if object.is_initialized
      nil
    end

    def to_openstudio(openstudio_model)
      # create construction and set identifier
      os_construction = OpenStudio::Model::Construction.new(openstudio_model)
      os_construction.setName(@hash[:identifier])
      unless @hash[:display_name].nil?
        os_construction.setDisplayName(@hash[:display_name])
      end
      # create material vector
      os_materials = OpenStudio::Model::MaterialVector.new
      # loop through each layer and add to material vector
      if $simple_window_cons && @hash[:u_factor]
        os_simple_glazing = OpenStudio::Model::SimpleGlazing.new(openstudio_model)
        os_simple_glazing.setName(@hash[:identifier] + '_SimpleGlazSys')
        os_simple_glazing.setUFactor(@hash[:u_factor])
        os_simple_glazing.setSolarHeatGainCoefficient(@hash[:shgc])
        os_simple_glazing.setVisibleTransmittance(@hash[:vt])
        os_materials << os_simple_glazing
      else
        if @hash.key?(:layers)
          mat_key = :layers
        else
          mat_key = :materials
        end
        @hash[mat_key].each do |material_identifier|
          material = openstudio_model.getMaterialByName(material_identifier)
          unless material.empty?
            os_material = material.get
            os_materials << os_material
          end
        end
      end
      os_construction.setLayers(os_materials)

      os_construction
    end

  end #WindowConstructionAbridged
end #Honeybee




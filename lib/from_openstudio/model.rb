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

require 'honeybee/model'

require 'from_openstudio/geometry/room'
require 'from_openstudio/geometry/shade'
require 'from_openstudio/material/opaque'
require 'from_openstudio/material/opaque_no_mass'
require 'from_openstudio/material/window_simpleglazsys'
require 'from_openstudio/material/window_glazing'
require 'from_openstudio/material/window_blind'
require 'from_openstudio/material/window_gas'
require 'from_openstudio/material/window_gas_custom'
require 'from_openstudio/material/window_gas_mixture'
require 'from_openstudio/construction/air'
require 'from_openstudio/construction/opaque'
require 'from_openstudio/construction/window'
require 'from_openstudio/construction/shade'
require 'from_openstudio/construction_set'

require 'openstudio'

module Honeybee
  class Model

    # Create Ladybug Energy Model JSON from OpenStudio Model
    def self.translate_from_openstudio(openstudio_model)
      hash = {}
      hash[:type] = 'Model'
      hash[:identifier] = 'Model'
      hash[:display_name] = 'Model'
      hash[:units] = 'Meters'
      hash[:tolerance] = 0.01
      hash[:angle_tolerance] = 1.0

      # Hashes for all constructions in the model
      $opaque_constructions = {}
      $window_constructions = {}
      $shade_constructions = {}

      hash[:properties] = properties_from_model(openstudio_model)

      rooms = rooms_from_model(openstudio_model)
      hash[:rooms] = rooms if !rooms.empty?

      orphaned_shades = orphaned_shades_from_model(openstudio_model)
      hash[:orphaned_shades] = orphaned_shades if !orphaned_shades.empty?

      unless $shade_constructions.empty?
        shade_constructions_from_model($shade_constructions).each do |shade_const|
          hash[:properties][:energy][:constructions] << shade_const
        end
      end

      Model.new(hash)
    end

    # Create Ladybug Energy Model JSON from OSM file
    def self.translate_from_osm_file(file)
      vt = OpenStudio::OSVersion::VersionTranslator.new
      openstudio_model = vt.loadModel(file)
      raise "Cannot load OSM file at '#{}'" if openstudio_model.empty?
      self.translate_from_openstudio(openstudio_model.get)
    end

    # Create Ladybug Energy Model JSON from gbXML file
    def self.translate_from_gbxml_file(file)
      translator = OpenStudio::GbXML::GbXMLReverseTranslator.new
      openstudio_model = translator.loadModel(file)
      raise "Cannot load gbXML file at '#{}'" if openstudio_model.empty?
      # remove any shade groups that were translated as spaces
      os_model = openstudio_model.get
      spaces = os_model.getSpaces()
      spaces.each do |space|
        if space.surfaces.length() == 0
          space.remove()
        end
      end
      self.translate_from_openstudio(os_model)
    end

    # Create Ladybug Energy Model JSON from IDF file
    def self.translate_from_idf_file(file)
      translator = OpenStudio::EnergyPlus::ReverseTranslator.new
      openstudio_model = translator.loadModel(file)
      raise "Cannot load IDF file at '#{}'" if openstudio_model.empty?
      self.translate_from_openstudio(openstudio_model.get)
    end

    def self.properties_from_model(openstudio_model)
      hash = {}
      hash[:type] = 'ModelProperties'
      hash[:energy] = energy_properties_from_model(openstudio_model)
      hash
    end

    def self.energy_properties_from_model(openstudio_model)
      hash = {}
      hash[:type] = 'ModelEnergyProperties'
      hash[:constructions] = []
      hash[:constructions] = constructions_from_model(openstudio_model)
      hash[:materials] = materials_from_model(openstudio_model)
      hash[:construction_sets] = []
      hash[:construction_sets] = constructionsets_from_model(openstudio_model)

      hash
    end

    def self.rooms_from_model(openstudio_model)
      result = []
      openstudio_model.getSpaces.each do |space|
        result << Room.from_space(space)
      end
      result
    end

    def self.orphaned_shades_from_model(openstudio_model)
      result = []
      openstudio_model.getShadingSurfaceGroups.each do |shading_surface_group|
        shading_surface_type = shading_surface_group.shadingSurfaceType
        if shading_surface_type == 'Site' || shading_surface_type == 'Building'
          site_transformation = shading_surface_group.siteTransformation
          shading_surface_group.shadingSurfaces.each do |shading_surface|
            result << Shade.from_shading_surface(shading_surface, site_transformation)
          end
        end
      end
      result
    end

    # Create HB Material from OpenStudio Materials
    def self.materials_from_model(openstudio_model)
      result = []

      # TODO: Loop through all materials and add puts statement for unsupported materials.
      
      # Create HB EnergyMaterial from OpenStudio Material
      openstudio_model.getStandardOpaqueMaterials.each do |material|
        result << EnergyMaterial.from_material(material)
      end

      # Create HB EnergyMaterialNoMass from OpenStudio MasslessOpaque Materials
      openstudio_model.getMasslessOpaqueMaterials.each do |material|
        result << EnergyMaterialNoMass.from_material(material)
      end

      # Create HB EnergyMaterialNoMass from OpenStudio AirGap materials
      openstudio_model.getAirGaps.each do|material|
        result << EnergyMaterialNoMass.from_material(material)
      end

      # Create HB WindowMaterialSimpleGlazSys from OpenStudio Material
      openstudio_model.getSimpleGlazings.each do |material|
        result << EnergyWindowMaterialSimpleGlazSys.from_material(material)
      end
      # Create HB EnergyWindowMaterialGlazing from OpenStudio Material
      openstudio_model.getStandardGlazings.each do |material|
        result << EnergyWindowMaterialGlazing.from_material(material)
      end
      # Create HB EnergyWindowMaterialBlind from OpenStudio Material
      openstudio_model.getBlinds.each do |material|
        result << EnergyWindowMaterialBlind.from_material(material)
      end
      openstudio_model.getGass.each do |material|
        # Create HB WindowGasCustom from OpenStudio Material
        if material.gasType == 'Custom'
          result << EnergyWindowMaterialGasCustom.from_material(material)
        else
        # Create HB WindowGas from OpenStudio Material
          result << EnergyWindowMaterialGas.from_material(material)
        end
      end
      # Create HB EnergyWindowMaterialGasMixture from OpenStudio Material
      openstudio_model.getGasMixtures.each do |material|
        result << EnergyWindowMaterialGasMixture.from_material(material)
      end

      result
    end

    # Create HB Construction from OpenStudio Materials
    def self.constructions_from_model(openstudio_model)
      result = []

      # Create HB AirConstruction from OpenStudio Construction
      openstudio_model.getConstructionAirBoundarys.each do |construction|
        result << AirBoundaryConstructionAbridged.from_construction(construction)
      end

      # Create HB WindowConstruction from OpenStudio Construction
      openstudio_model.getConstructions.each do |construction|
        window_construction = false
        opaque_construction = false
        material = construction.layers[0]
        unless material.nil?
          if material.to_StandardGlazing.is_initialized or material.to_SimpleGlazing.is_initialized
            window_construction = true
          elsif material.to_StandardOpaqueMaterial.is_initialized or material.to_MasslessOpaqueMaterial.is_initialized
            opaque_construction = true
          end
          if window_construction == true
            constr_hash = WindowConstructionAbridged.from_construction(construction)
            $window_constructions[constr_hash[:identifier]] = constr_hash
            result << constr_hash
          end
          if opaque_construction == true
            constr_hash = OpaqueConstructionAbridged.from_construction(construction)
            $opaque_constructions[constr_hash[:identifier]] = constr_hash
            result << constr_hash
          end
        end
      end

      result
    end

    # Create HB ConstructionSets from OpenStudio Construction Set
    def self.constructionsets_from_model(openstudio_model)
      result = []

      openstudio_model.getDefaultConstructionSets.each do |construction_set|
        if construction_set.nameString != "Default Generic Construction Set"
          result << ConstructionSetAbridged.from_construction_set(construction_set)
        end
      end

      result
    end
  
    def self.shade_constructions_from_model(shade_constructions)
      result = []

        shade_constructions.each do |key, value|
          result << ShadeConstruction.from_construction(value)
        end

      result
    end

  end # Model
end # Honeybee

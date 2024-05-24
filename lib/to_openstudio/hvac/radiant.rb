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

# Note: This file is derived from the "Radiant Slab with DOAS" measure
# https://github.com/NREL/openstudio-model-articulation-gem/tree/develop/lib/measures/radiant_slab_with_doas
# It is intended that this file be updated if changes are made to the original measure

class OpenStudio::Model::Model
  # Adds a radiant HVAC system to the model
  def add_radiant_hvac_system(std, system_type, zones, rad_props)
    # the 'zones' argument includes zones that have heating, cooling, or both
    conditioned_zones = zones.select { |zone| std.thermal_zone_heated?(zone) && std.thermal_zone_cooled?(zone) }

    # get the climate zone from the model, which will help set water temerpatures
    climate_zone_obj = self.getClimateZones.getClimateZone('ASHRAE', 2006)
    if climate_zone_obj.empty
      climate_zone_obj = self.getClimateZones.getClimateZone('ASHRAE', 2013)
    end
    if climate_zone_obj.empty || climate_zone_obj.value == ''
        climate_zone = ''
      else
        climate_zone = climate_zone_obj.value
      end
    
    # get the radiant hot water temperature based on the climate zone
    case climate_zone
    when '0', '1'
      radiant_htg_dsgn_sup_wtr_temp_f = 90.0
      cz_mult = 2
    when '2', '2A', '2B'
      radiant_htg_dsgn_sup_wtr_temp_f = 100.0
      cz_mult = 2
    when '3', '3A', '3B', '3C'
      radiant_htg_dsgn_sup_wtr_temp_f = 100.0
      cz_mult = 3
    when '4', '4A', '4B', '4C'
      radiant_htg_dsgn_sup_wtr_temp_f = 100.0
      cz_mult = 4
    when '5', '5A', '5B', '5C'
      radiant_htg_dsgn_sup_wtr_temp_f = 110.0
      cz_mult = 4
    when '6', '6A', '6B'
      radiant_htg_dsgn_sup_wtr_temp_f = 120.0
      cz_mult = 4
    when '7', '8'
      radiant_htg_dsgn_sup_wtr_temp_f = 120.0
      cz_mult = 5
    else  # unrecognized climate zone; default to climate zone 4
      radiant_htg_dsgn_sup_wtr_temp_f = 100.0
      cz_mult = 4
    end

    # create the hot water loop
    if system_type.include? 'ASHP'
      boiler_fuel_type = 'ASHP'
    elsif system_type.include? 'Boiler'
      boiler_fuel_type = 'NaturalGas'
    elsif system_type.include? 'DHW'
      boiler_fuel_type = 'DistrictHeating'
    end
    hot_water_loop = std.model_add_hw_loop(
      self,
      boiler_fuel_type,
      dsgn_sup_wtr_temp: radiant_htg_dsgn_sup_wtr_temp_f,
      dsgn_sup_wtr_temp_delt: 10.0)

    # create the chilled water loop
    if system_type.include? 'Radiant_Chiller'  # water-cooled chiller
      # make condenser water loop
      fan_type = std.model_cw_loop_cooling_tower_fan_type(self)
      condenser_water_loop = std.model_add_cw_loop(
        self,
        cooling_tower_type: 'Open Cooling Tower',
        cooling_tower_fan_type: 'Propeller or Axial',
        cooling_tower_capacity_control: fan_type,
        number_of_cells_per_tower: 1,
        number_cooling_towers: 1)
      # make chilled water loop
      chilled_water_loop = std.model_add_chw_loop(
        self,
        chw_pumping_type: 'const_pri_var_sec',
        dsgn_sup_wtr_temp: 55.0,
        dsgn_sup_wtr_temp_delt: 5.0,
        chiller_cooling_type: 'WaterCooled',
        condenser_water_loop: condenser_water_loop)
    elsif system_type.include? 'Radiant_ACChiller'  # air-cooled chiller
      chilled_water_loop = std.model_add_chw_loop(
        self,
        chw_pumping_type: 'const_pri_var_sec',
        dsgn_sup_wtr_temp: 55.0,
        dsgn_sup_wtr_temp_delt: 5.0,
        chiller_cooling_type: 'AirCooled')
    else  # district chilled water cooled
        chilled_water_loop = std.model_add_chw_loop(
          self,
          cooling_fuel: 'DistrictCooling',
          chw_pumping_type: 'const_pri_var_sec',
          dsgn_sup_wtr_temp: 55.0,
          dsgn_sup_wtr_temp_delt: 5.0)
    end

    # get the various controls for the radiant system
    if rad_props[:switch_over_time]
      switch_over_time = rad_props[:switch_over_time]
    else
      switch_over_time = 24
    end

    # add radiant system to the conditioned zones
    include_carpet = false
    control_strategy = 'proportional_control'
    if rad_props[:radiant_type]
      radiant_type = rad_props[:radiant_type].downcase
      if radiant_type == 'floorwithcarpet'
        radiant_type = 'floor'
        include_carpet = true
      elsif radiant_type == 'ceilingmetalpanel' || radiant_type == 'floorwithhardwood'
        control_strategy = 'default'
      end
    else
      radiant_type = 'floor'
    end

    radiant_loops = model_add_low_temp_radiant(
      std, conditioned_zones, hot_water_loop, chilled_water_loop,
      radiant_type: radiant_type,
      control_strategy: control_strategy,
      include_carpet: include_carpet,
      switch_over_time: switch_over_time,
      cz_mult: cz_mult)

    # if the equipment includes a DOAS, then add it
    if system_type.include? 'DOAS_'
      std.model_add_doas(self, conditioned_zones)
    end

  end

  def model_add_low_temp_radiant(std,
                                 thermal_zones,
                                 hot_water_loop,
                                 chilled_water_loop,
                                 radiant_type: 'floor',
                                 include_carpet: true,
                                 carpet_thickness_in: 0.25,
                                 model_occ_hr_start: 1.0,
                                 model_occ_hr_end: 24.0,
                                 control_strategy: 'proportional_control',
                                 proportional_gain: 0.3,
                                 switch_over_time: 24.0,
                                 cz_mult: 4)

    # create internal source constructions for surfaces
    OpenStudio.logFree(OpenStudio::Warn, 'openstudio.Model.Model', "Replacing constructions with new radiant slab constructions.")

    # create materials
    # concrete slab materials
    mat_concrete_3_5in = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'MediumRough', 0.0889, 2.31, 2322, 832)
    mat_concrete_3_5in.setName('Radiant Slab Concrete - 3.5 in.')
    mat_concrete_1_5in = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'MediumRough', 0.0381, 2.31, 2322, 832)
    mat_concrete_1_5in.setName('Radiant Slab Concrete - 1.5 in')

    metal_mat = nil
    air_gap_mat = nil
    wood_mat = nil
    wood_floor_insulation = nil
    gypsum_ceiling_mat = nil
    if radiant_type == 'ceilingmetalpanel'
      metal_mat = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'MediumSmooth', 0.003175, 30, 7680, 418)
      metal_mat.setName('Radiant Metal Layer - 0.125 in')
      air_gap_mat = OpenStudio::Model::MasslessOpaqueMaterial.new(self, 'Smooth', 0.004572)
      air_gap_mat.setName('Generic Ceiling Air Gap - R 0.025')
    elsif radiant_type == 'floorwithhardwood'
      wood_mat = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'MediumSmooth', 0.01905, 0.15, 608, 1629)
      wood_mat.setName('Radiant Hardwood Flooring - 0.75 in')
      wood_floor_insulation = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'Rough', 0.0508, 0.02, 56.06, 1210)
      wood_floor_insulation.setName('Radiant Subfloor Insulation - 4.0 in')
      gypsum_ceiling_mat = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'Smooth', 0.0127, 0.16, 800, 1089)
      gypsum_ceiling_mat.setName('Gypsum Ceiling for Radiant Hardwood Flooring - 0.5 in')
    end

    mat_refl_roof_membrane = self.getStandardOpaqueMaterialByName('Roof Membrane - Highly Reflective')
    if mat_refl_roof_membrane.is_initialized
      mat_refl_roof_membrane = self.getStandardOpaqueMaterialByName('Roof Membrane - Highly Reflective').get
    else
      mat_refl_roof_membrane = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'VeryRough', 0.0095, 0.16, 1121.29, 1460)
      mat_refl_roof_membrane.setThermalAbsorptance(0.75)
      mat_refl_roof_membrane.setSolarAbsorptance(0.45)
      mat_refl_roof_membrane.setVisibleAbsorptance(0.7)
      mat_refl_roof_membrane.setName('Roof Membrane - Highly Reflective')
    end

    if include_carpet
      carpet_thickness_m = OpenStudio.convert(carpet_thickness_in / 12.0, 'ft', 'm').get
      conductivity_si = 0.06
      conductivity_ip = OpenStudio.convert(conductivity_si, 'W/m*K', 'Btu*in/hr*ft^2*R').get
      r_value_ip = carpet_thickness_in * (1 / conductivity_ip)
      mat_thin_carpet_tile = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'MediumRough', carpet_thickness_m, conductivity_si, 288, 1380)
      mat_thin_carpet_tile.setThermalAbsorptance(0.9)
      mat_thin_carpet_tile.setSolarAbsorptance(0.7)
      mat_thin_carpet_tile.setVisibleAbsorptance(0.8)
      mat_thin_carpet_tile.setName("Radiant Slab Thin Carpet Tile R-#{r_value_ip.round(2)}")
    end

    # set exterior slab insulation thickness based on climate zone
    slab_insulation_thickness_m = 0.0254 * cz_mult
    mat_slab_insulation = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'Rough', slab_insulation_thickness_m, 0.02, 56.06, 1210)
    mat_slab_insulation.setName("Radiant Ground Slab Insulation - #{cz_mult} in.")

    ext_insulation_thickness_m = 0.0254 * (cz_mult + 1)
    mat_ext_insulation = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'Rough', ext_insulation_thickness_m, 0.02, 56.06, 1210)
    mat_ext_insulation.setName("Radiant Exterior Slab Insulation - #{cz_mult + 1} in.")

    roof_insulation_thickness_m = 0.0254 * (cz_mult + 1) * 2
    mat_roof_insulation = OpenStudio::Model::StandardOpaqueMaterial.new(self, 'Rough', roof_insulation_thickness_m, 0.02, 56.06, 1210)
    mat_roof_insulation.setName("Radiant Exterior Ceiling Insulation - #{(cz_mult + 1) * 2} in.")

    # create radiant internal source constructions
    radiant_ground_slab_construction = nil
    radiant_exterior_slab_construction = nil
    radiant_interior_floor_slab_construction = nil
    radiant_interior_ceiling_slab_construction = nil
    radiant_ceiling_slab_construction = nil
    radiant_interior_ceiling_metal_construction = nil
    radiant_ceiling_metal_construction = nil

    if radiant_type == 'floor'
      layers = []
      layers << mat_slab_insulation
      layers << mat_concrete_3_5in
      layers << mat_concrete_1_5in
      layers << mat_thin_carpet_tile if include_carpet
      radiant_ground_slab_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_ground_slab_construction.setName('Radiant Ground Slab Construction')
      radiant_ground_slab_construction.setSourcePresentAfterLayerNumber(2)
      radiant_ground_slab_construction.setTemperatureCalculationRequestedAfterLayerNumber(3)
      radiant_ground_slab_construction.setTubeSpacing(0.2286) # 9 inches

      layers = []
      layers << mat_ext_insulation
      layers << mat_concrete_3_5in
      layers << mat_concrete_1_5in
      layers << mat_thin_carpet_tile if include_carpet
      radiant_exterior_slab_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_exterior_slab_construction.setName('Radiant Exterior Slab Construction')
      radiant_exterior_slab_construction.setSourcePresentAfterLayerNumber(2)
      radiant_exterior_slab_construction.setTemperatureCalculationRequestedAfterLayerNumber(3)
      radiant_exterior_slab_construction.setTubeSpacing(0.2286) # 9 inches

      layers = []
      layers << mat_concrete_3_5in
      layers << mat_concrete_1_5in
      layers << mat_thin_carpet_tile if include_carpet
      radiant_interior_floor_slab_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_interior_floor_slab_construction.setName('Radiant Interior Floor Slab Construction')
      radiant_interior_floor_slab_construction.setSourcePresentAfterLayerNumber(1)
      radiant_interior_floor_slab_construction.setTemperatureCalculationRequestedAfterLayerNumber(2)
      radiant_interior_floor_slab_construction.setTubeSpacing(0.2286) # 9 inches
    elsif radiant_type == 'ceiling'
      layers = []
      layers << mat_thin_carpet_tile if include_carpet
      layers << mat_concrete_3_5in
      layers << mat_concrete_1_5in
      radiant_interior_ceiling_slab_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_interior_ceiling_slab_construction.setName('Radiant Interior Ceiling Slab Construction')
      slab_src_loc = include_carpet ? 2 : 1
      radiant_interior_ceiling_slab_construction.setSourcePresentAfterLayerNumber(slab_src_loc)
      radiant_interior_ceiling_slab_construction.setTemperatureCalculationRequestedAfterLayerNumber(slab_src_loc + 1)
      radiant_interior_ceiling_slab_construction.setTubeSpacing(0.2286) # 9 inches

      layers = []
      layers << mat_refl_roof_membrane
      layers << mat_roof_insulation
      layers << mat_concrete_3_5in
      layers << mat_concrete_1_5in
      radiant_ceiling_slab_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_ceiling_slab_construction.setName('Radiant Exterior Ceiling Slab Construction')
      radiant_ceiling_slab_construction.setSourcePresentAfterLayerNumber(3)
      radiant_ceiling_slab_construction.setTemperatureCalculationRequestedAfterLayerNumber(4)
      radiant_ceiling_slab_construction.setTubeSpacing(0.2286) # 9 inches
    elsif radiant_type == 'ceilingmetalpanel'
      layers = []
      layers << mat_concrete_3_5in
      layers << air_gap_mat
      layers << metal_mat
      layers << metal_mat
      radiant_interior_ceiling_metal_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_interior_ceiling_metal_construction.setName('Radiant Interior Ceiling Metal Construction')
      radiant_interior_ceiling_metal_construction.setSourcePresentAfterLayerNumber(3)
      radiant_interior_ceiling_metal_construction.setTemperatureCalculationRequestedAfterLayerNumber(4)
      radiant_interior_ceiling_metal_construction.setTubeSpacing(0.1524) # 6 inches
      
      layers = []
      layers << mat_refl_roof_membrane
      layers << mat_roof_insulation
      layers << mat_concrete_3_5in
      layers << air_gap_mat
      layers << metal_mat
      layers << metal_mat
      radiant_ceiling_metal_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_ceiling_metal_construction.setName('Radiant Ceiling Metal Construction')
      radiant_ceiling_metal_construction.setSourcePresentAfterLayerNumber(5)
      radiant_ceiling_metal_construction.setTemperatureCalculationRequestedAfterLayerNumber(6)
      radiant_ceiling_metal_construction.setTubeSpacing(0.1524) # 6 inches
    elsif radiant_type == 'floorwithhardwood'
      layers = []
      layers << mat_slab_insulation
      layers << mat_concrete_3_5in
      layers << wood_mat
      layers << mat_thin_carpet_tile if include_carpet
      radiant_ground_wood_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_ground_wood_construction.setName('Radiant Ground Slab Wood Floor Construction')
      radiant_ground_wood_construction.setSourcePresentAfterLayerNumber(2)
      radiant_ground_wood_construction.setTemperatureCalculationRequestedAfterLayerNumber(3)
      radiant_ground_wood_construction.setTubeSpacing(0.2286) # 9 inches

      layers = []
      layers << mat_ext_insulation
      layers << wood_mat
      layers << mat_thin_carpet_tile if include_carpet
      radiant_exterior_wood_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_exterior_wood_construction.setName('Radiant Exterior Wood Floor Construction')
      radiant_exterior_wood_construction.setSourcePresentAfterLayerNumber(1)
      radiant_exterior_wood_construction.setTemperatureCalculationRequestedAfterLayerNumber(2)
      radiant_exterior_wood_construction.setTubeSpacing(0.2286) # 9 inches

      layers = []
      layers << gypsum_ceiling_mat
      layers << wood_floor_insulation
      layers << wood_mat
      layers << mat_thin_carpet_tile if include_carpet
      radiant_interior_wood_floor_construction = OpenStudio::Model::ConstructionWithInternalSource.new(layers)
      radiant_interior_wood_floor_construction.setName('Radiant Interior Wooden Floor Construction')
      radiant_interior_wood_floor_construction.setSourcePresentAfterLayerNumber(2)
      radiant_interior_wood_floor_construction.setTemperatureCalculationRequestedAfterLayerNumber(3)
      radiant_interior_wood_floor_construction.setTubeSpacing(0.2286) # 9 inches
    end

    # default temperature controls for radiant system
    zn_radiant_htg_dsgn_temp_f = 68.0
    zn_radiant_htg_dsgn_temp_c = OpenStudio.convert(zn_radiant_htg_dsgn_temp_f, 'F', 'C').get
    zn_radiant_clg_dsgn_temp_f = 74.0
    zn_radiant_clg_dsgn_temp_c = OpenStudio.convert(zn_radiant_clg_dsgn_temp_f, 'F', 'C').get

    htg_control_temp_sch = std.model_add_constant_schedule_ruleset(
      self,
      zn_radiant_htg_dsgn_temp_c,
      name = "Zone Radiant Loop Heating Threshold Temperature Schedule - #{zn_radiant_htg_dsgn_temp_f.round(0)}F")
    clg_control_temp_sch = std.model_add_constant_schedule_ruleset(
      self,
      zn_radiant_clg_dsgn_temp_c,
      name = "Zone Radiant Loop Cooling Threshold Temperature Schedule - #{zn_radiant_clg_dsgn_temp_f.round(0)}F")
    throttling_range_f = 4.0 # 2 degF on either side of control temperature
    throttling_range_c = OpenStudio.convert(throttling_range_f, 'F', 'C').get

    # make a low temperature radiant loop for each zone
    radiant_loops = []
    thermal_zones.each do |zone|
      OpenStudio.logFree(OpenStudio::Info, 'openstudio.Model.Model', "Adding radiant loop for #{zone.name}.")
      if zone.name.to_s.include? ':'
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.Model.Model', "Thermal zone '#{zone.name}' has a restricted character ':' in the name and will not work with some EMS and output reporting objects. Please rename the zone.")
      end

      # assign internal source construction to floors in zone
      srf_count = 0
      zone.spaces.each do |space|
        space.surfaces.each do |surface|
          if surface.isAirWall
            OpenStudio.logFree(OpenStudio::Info, 'openstudio.Model.Model', "Surface #{surface.name} cannot be set to a Radiant Construction as it is an AirBoundary.")
          elsif radiant_type == 'floor'
            if surface.surfaceType == 'Floor'
              srf_count += 1
              if surface.outsideBoundaryCondition == 'Ground'
                surface.setConstruction(radiant_ground_slab_construction)
              elsif surface.outsideBoundaryCondition == 'Outdoors'
                surface.setConstruction(radiant_exterior_slab_construction)
              else # interior floor
                surface.setConstruction(radiant_interior_floor_slab_construction)
              end
            end
          elsif radiant_type == 'ceiling'
            if surface.surfaceType == 'RoofCeiling'
              srf_count += 1
              if surface.outsideBoundaryCondition == 'Outdoors'
                surface.setConstruction(radiant_ceiling_slab_construction)
              else # interior ceiling
                surface.setConstruction(radiant_interior_ceiling_slab_construction)
              end
            end
          elsif radiant_type == 'ceilingmetalpanel'
            if surface.surfaceType == 'RoofCeiling'
              srf_count += 1
              if surface.outsideBoundaryCondition == 'Outdoors'
                surface.setConstruction(radiant_ceiling_metal_construction)
              else # interior ceiling
                surface.setConstruction(radiant_interior_ceiling_metal_construction)
              end
            end
          elsif radiant_type == 'floorwithhardwood'
            if surface.surfaceType == 'Floor'
              srf_count += 1
              if surface.outsideBoundaryCondition == 'Ground'
                surface.setConstruction(radiant_ground_wood_construction)
              elsif surface.outsideBoundaryCondition == 'Outdoors'
                surface.setConstruction(radiant_exterior_wood_construction)
              else # interior floor
                surface.setConstruction(radiant_interior_wood_floor_construction)
              end
            end
          end
        end
      end

      # ignore the Zone if it has not thermally active Faces
      if srf_count == 0
        next
      end

      # create radiant coils
      if hot_water_loop
        radiant_loop_htg_coil = OpenStudio::Model::CoilHeatingLowTempRadiantVarFlow.new(self, htg_control_temp_sch)
        radiant_loop_htg_coil.setName("#{zone.name} Radiant Loop Heating Coil")
        radiant_loop_htg_coil.setHeatingControlThrottlingRange(throttling_range_c)
        hot_water_loop.addDemandBranchForComponent(radiant_loop_htg_coil)
      else
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.Model.Model', 'Radiant loops require a hot water loop, but none was provided.')
      end

      if chilled_water_loop
        radiant_loop_clg_coil = OpenStudio::Model::CoilCoolingLowTempRadiantVarFlow.new(self, clg_control_temp_sch)
        radiant_loop_clg_coil.setName("#{zone.name} Radiant Loop Cooling Coil")
        radiant_loop_clg_coil.setCoolingControlThrottlingRange(throttling_range_c)
        chilled_water_loop.addDemandBranchForComponent(radiant_loop_clg_coil)
      else
        OpenStudio.logFree(OpenStudio::Error, 'openstudio.Model.Model', 'Radiant loops require a chilled water loop, but none was provided.')
      end

      radiant_avail_sch = self.alwaysOnDiscreteSchedule
      radiant_loop = OpenStudio::Model::ZoneHVACLowTempRadiantVarFlow.new(self,
                                                                          radiant_avail_sch,
                                                                          radiant_loop_htg_coil,
                                                                          radiant_loop_clg_coil)

      # radiant loop surfaces
      radiant_loop.setName("#{zone.name} Radiant Loop")
      if radiant_type == 'floor'
        radiant_loop.setRadiantSurfaceType('Floors')
      elsif radiant_type == 'ceiling'
        radiant_loop.setRadiantSurfaceType('Ceilings')
      elsif radiant_type == 'ceilingmetalpanel'
        radiant_loop.setRadiantSurfaceType('Ceilings')
      elsif radiant_type == 'floorwithhardwood'
        radiant_loop.setRadiantSurfaceType('Floors')
      end

      # radiant loop layout details
      radiant_loop.setHydronicTubingInsideDiameter(0.015875) # 5/8 in. ID, 3/4 in. OD
      # @todo include a method to determine tubing length in the zone
      # loop_length = 7*zone.floorArea
      # radiant_loop.setHydronicTubingLength()
      radiant_loop.setNumberofCircuits('CalculateFromCircuitLength')
      radiant_loop.setCircuitLength(106.7)

      # radiant loop controls
      radiant_loop.setTemperatureControlType('MeanAirTemperature')
      radiant_loop.addToThermalZone(zone)
      radiant_loops << radiant_loop

      # rename nodes before adding EMS code
      std.rename_plant_loop_nodes(self)

      # TODO: Un-comment this once these controls are fixed (Matt made a lot of changes for OpenStudio 3.8)
      # set radiant loop controls
      #if control_strategy == 'proportional_control'
      #  std.model_add_radiant_proportional_controls(self, zone, radiant_loop,
      #                                              radiant_temperature_control_type: 'SurfaceFaceTemperature',
      #                                              use_zone_occupancy_for_control: true,
      #                                              occupied_percentage_threshold: 0.10,
      #                                              model_occ_hr_start: model_occ_hr_start,
      #                                              model_occ_hr_end: model_occ_hr_end,
      #                                              proportional_gain: proportional_gain,
      #                                              switch_over_time: switch_over_time)
      #end
    end

    return radiant_loops
  end

end
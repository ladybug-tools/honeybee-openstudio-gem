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
  class VentilationOpening < ModelObject
    attr_reader :errors, :warnings

    def initialize(hash = {})
      super(hash)
    end

    def defaults
      @@schema[:components][:schemas][:VentilationOpening][:properties]
    end

    def defaults_control
      @@schema[:components][:schemas][:VentilationControlAbridged][:properties]
    end

    def to_openstudio(openstudio_model, parent, vent_control_hash)
      # create wind and stack object and set identifier
      os_opening = OpenStudio::Model::ZoneVentilationWindandStackOpenArea.new(openstudio_model)
      os_opening.setName(parent.name.get + '_Opening')

      # assign the opening area
      if @hash[:fraction_area_operable]
        os_opening.setOpeningArea(@hash[:fraction_area_operable]  * parent.netArea)
      else
        os_opening.setOpeningArea(
          defaults[:fraction_area_operable][:default] * parent.netArea)
      end

      # assign the height
      if @hash[:fraction_height_operable]
        os_opening.	setHeightDifference(
          @hash[:fraction_height_operable]  * compute_height(parent))
      else
        os_opening.	setHeightDifference(
          defaults[:fraction_height_operable][:default] * compute_height(parent))
      end

      # assign the azimuth
      az_degrees = parent.azimuth * 180 / Math::PI
      os_opening.setEffectiveAngle(az_degrees.round())

      # assign the discharge coefficient
      if @hash[:discharge_coefficient]
        os_opening.setDischargeCoefficientforOpening(@hash[:discharge_coefficient])
      else
        os_opening.setDischargeCoefficientforOpening(
          defaults[:discharge_coefficient][:default])
      end

      # assign the wind pressure coefficient
      if @hash[:wind_cross_vent]
        os_opening.autocalculateOpeningEffectiveness()
      else
        os_opening.setOpeningEffectiveness(0)
      end

      # set all of the ventilation control properties
      if vent_control_hash
        # assign min_indoor_temperature
        if vent_control_hash[:min_indoor_temperature]
          os_opening.setMinimumIndoorTemperature(vent_control_hash[:min_indoor_temperature])
        else
          os_opening.setMinimumIndoorTemperature(
            defaults_control[:min_indoor_temperature][:default])
        end
        # assign max_indoor_temperature
        if vent_control_hash[:max_indoor_temperature]
          os_opening.setMaximumIndoorTemperature(vent_control_hash[:max_indoor_temperature])
        else
          os_opening.setMaximumIndoorTemperature(
            defaults_control[:max_indoor_temperature][:default])
        end
        # assign min_outdoor_temperature
        if vent_control_hash[:min_outdoor_temperature]
          os_opening.setMinimumOutdoorTemperature(vent_control_hash[:min_outdoor_temperature])
        else
          os_opening.setMinimumOutdoorTemperature(
            defaults_control[:min_outdoor_temperature][:default])
        end
        # assign max_outdoor_temperature
        if vent_control_hash[:max_outdoor_temperature]
          os_opening.setMaximumOutdoorTemperature(vent_control_hash[:max_outdoor_temperature])
        else
          os_opening.setMaximumOutdoorTemperature(
            defaults_control[:max_outdoor_temperature][:default])
        end
        # assign delta_temperature
        if vent_control_hash[:delta_temperature]
          os_opening.setDeltaTemperature(vent_control_hash[:delta_temperature])
        else
          os_opening.setDeltaTemperature(
            defaults_control[:delta_temperature][:default])
        end
        # assign schedule if it exists
        if vent_control_hash[:schedule]
          vent_sch = openstudio_model.getScheduleByName(vent_control_hash[:schedule])
          unless vent_sch.empty?
            vent_sch_object = vent_sch.get
            os_opening.setOpeningAreaFractionSchedule(vent_sch_object)
          end
        end
      end

      os_opening
    end

    def to_openstudio_afn(openstudio_model, parent)
      # process the flow_coefficient_closed and set it to a very small number if it's 0
      if @hash[:flow_coefficient_closed] and @hash[:flow_coefficient_closed] != 0
        flow_coefficient = @hash[:flow_coefficient_closed]
      else
        flow_coefficient = 1.0e-09  # set it to a very small number
      end

      # create the simple opening object for the Aperture or Door using default values
      flow_exponent = defaults[:flow_exponent_closed][:default].to_f
      two_way_thresh = defaults[:two_way_threshold][:default].to_f
      discharge_coeff = defaults[:discharge_coefficient][:default].to_f
      os_opening = OpenStudio::Model::AirflowNetworkSimpleOpening.new(
        openstudio_model, flow_coefficient, flow_exponent, two_way_thresh, discharge_coeff)

      # assign the flow exponent when the opening is closed
      if @hash[:flow_exponent_closed]
        os_opening.setAirMassFlowExponentWhenOpeningisClosed(@hash[:flow_exponent_closed])
      end
      # assign the minimum difference for two-way flow
      if @hash[:two_way_threshold]
        os_opening.setMinimumDensityDifferenceforTwoWayFlow(@hash[:two_way_threshold])
      end
      # assign the discharge coefficient
      if @hash[:discharge_coefficient]
        os_opening.setDischargeCoefficient(@hash[:discharge_coefficient])
      end

      # create the AirflowNetworkSurface 
      os_afn_srf = parent.getAirflowNetworkSurface(os_opening)

      # assign the opening area
      if @hash[:fraction_area_operable]
        open_fac = @hash[:fraction_area_operable]
      else
        open_fac = defaults[:fraction_area_operable][:default]
      end
      os_afn_srf.setWindowDoorOpeningFactorOrCrackFactor(open_fac)

      open_fac
    end

    def compute_height(surface)
      # derive the height (difference in z values) of a surface
      verts = surface.vertices
      min_pt = verts[0].z
      max_pt = verts[0].z
      verts.each do |v|
        if v.z < min_pt
          min_pt = v.z
        elsif v.z > max_pt
          max_pt = v.z
        end
      end
      # quarter the window height to get the height from midpoint of lower opening to neutral pressure level
      (max_pt - min_pt) / 4
    end

  end #VentilationOpening
end #FromHoneybee
  
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

require 'honeybee/extension'
require 'honeybee/model_object'

module Honeybee
  class Model
    attr_reader :errors, :warnings, :hash

    # Read Ladybug Energy Model JSON from disk
    def self.read_from_disk(file)
      hash = nil
      File.open(File.join(file), 'r') do |f|
        hash = JSON.parse(f.read, symbolize_names: true)
      end
      Model.new(hash)
    end

    # Load ModelObject from symbolized hash
    def initialize(hash)
      # initialize class variable @@extension only once
      @@extension ||= Extension.new
      @@schema ||= @@extension.schema
      @@standards ||= @@extension.standards

      @hash = hash
      @type = @hash[:type]
      raise 'Unknown model type' if @type.nil?
      raise "Incorrect model type '#{@type}'" unless @type == 'Model'

      if @hash[:version].nil?
        @hash[:version] = @@schema[:info][:version]
      end
    end

    # check if the model is valid
    def valid?
      if Gem.loaded_specs.has_key?("json-schema")
        return validation_errors.empty?
      else
        return true
      end
    end

    # return detailed model validation errors
    def validation_errors
      if Gem.loaded_specs.has_key?("json-schema")
        require 'json-schema'
        JSON::Validator.fully_validate(@@schema, @hash, :fragment => "#/components/schemas/Model")
      end
    end

    def defaults
      @@schema[:components][:schemas][:ModelEnergyProperties][:properties]
    end

  end # Model
end # Honeybee

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

module Honeybee
  class ModelObject
    # Base class from which all other objects in this module inherit.
    # Attributes and methods of this class should be overwritten in each inheriting object.

    attr_reader :errors, :warnings

    def method_missing(sym, *args)
      name = sym.to_s
      aname = name.sub('=', '')
      asym = aname.to_sym
      is_getter = args.empty? && @hash.key?(asym)
      is_setter = (name != aname) && (args.size == 1) && @hash.key?(asym)

      if is_getter
        return @hash[asym]
      elsif is_setter
        return @hash[asym] = args[0]
      end

      # do the regular thing
      super
    end

    # Read ModelObject JSON from disk
    def self.read_from_disk(file)
      hash = nil
      File.open(File.join(file), 'r') do |f|
        hash = JSON.parse(f.read, symbolize_names: true)
      end
      new(hash)
    end

    # Load ModelObject from symbolized hash
    def initialize(hash)
      # initialize class variable @@extension only once
      @@extension ||= Extension.new
      @@schema ||= @@extension.schema

      @hash = hash
      @type = @hash[:type]
      raise 'Unknown type' if @type.nil?
      raise "Incorrect model object type '#{@type}' for '#{self.class.name}'" unless allowable_types.include?(@type)
    end

    def allowable_types
      [self.class.name.split('::').last]
    end

    # hash containing the object defaults taken from the open API schema
    def defaults
      raise 'defaults not implemented for ModelObject, override in your class'
    end

    # check if the ModelObject is valid
    def valid?
      return validation_errors.empty?
    end

    # return detailed model validation errors
    def validation_errors
      if Gem.loaded_specs.has_key?("json-schema")
        require 'json-schema'
        # if this raises a 'Invalid fragment resolution for :fragment option' it is because @type
        # does not correspond to a definition in the schema
        JSON::Validator.fully_validate(@@schema, @hash, :fragment => "#/components/schemas/#{@type}")
      end
    end

    # remove illegal characters in identifier
    def self.clean_display_name(str)
      str.gsub(/[^[:ascii:]]/, '')
    end

    # remove illegal characters in identifier
    def self.clean_identifier(str)
      str.gsub(/[^.A-Za-z0-9_-]/, '_').gsub(' ', '_')
    end


  end # ModelObject
end # Honeybee

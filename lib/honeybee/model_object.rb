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
  class FakeOptionalString
    def initialize(str)
      @str = str
    end

    def empty?
      false
    end

    def get
      @str
    end
  end

  class ModelObject
    # Base class from which all other objects in this module inherit.
    # Attributes and methods of this class should be overwritten in each inheriting object.

    attr_reader :errors, :warnings

    @@encoding_options = {
      :invalid           => :replace,  # Replace invalid byte sequences
      :undef             => :replace,  # Replace anything not defined in ASCII
      :replace           => '',        # Use a blank for those replacements
      :universal_newline => true       # Always break lines with \n
    }


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
        hash = JSON.parse(File.read(f, :external_encoding => 'UTF-8',
          :internal_encoding => 'UTF-8'), symbolize_names: true, encoding: 'UTF-8')
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

    def self.truncate(string, max)
      string.length > max ? "#{string[0...max]}..." : string
    end

    # remove illegal characters in identifier
    def self.clean_name(str)
      ascii = str.encode(Encoding.find('ASCII'), **@@encoding_options)
      ascii = truncate(ascii, 97)
    end

    # remove illegal characters in identifier
    def self.clean_identifier(str)
      encode_str = str.encode(Encoding.find('ASCII'), **@@encoding_options)
      encode_str.gsub(/[^.A-Za-z0-9_-]/, '_').gsub(' ', '_')
      encode_str = truncate(encode_str, 97)
    end

    # Create methods to get and set display name
    if !OpenStudio::Model::ModelObject.method_defined?(:displayName)
      OpenStudio::Model::ModelObject.class_eval do
        define_method(:displayName) do
          result = additionalProperties.getFeatureAsString("DisplayName")
          if !result.empty?
            result = FakeOptionalString.new(result.get.force_encoding(Encoding::UTF_8))
          end
          result
        end
        define_method(:setDisplayName) do |value|
          additionalProperties.setFeature("DisplayName", value)
        end
      end
    end

  end # ModelObject
end # Honeybee

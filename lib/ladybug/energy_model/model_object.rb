# *******************************************************************************
# Ladybug Tools Energy Model Schema, Copyright (c) 2019, Alliance for Sustainable 
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

require 'json-schema'
require 'json'
require 'openstudio'

module Ladybug
  module EnergyModel
    class ModelObject
      attr_reader :errors, :warnings

      def method_missing(sym, *args)
        name = sym.to_s
        aname = name.sub("=","")
        asym = aname.to_sym
        is_getter = (args.size == 0) && @hash.key?(asym)
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
          hash = JSON::parse(f.read, {symbolize_names: true})
        end
        return self.new(hash)
      end
      
      # Load ModelObject from symbolized hash
      def initialize(hash)
        # initialize class variable @@extension only once
        @@extension ||= Extension.new
        @@schema ||= @@extension.schema

        hash = defaults.merge(hash)
        @hash = hash
        
        @type = @hash[:type]
        raise 'Unknown type' if @type.nil?
        
        @openstudio_object = nil
      end
      
      def defaults
        raise "defaults not implemented for ModelObject, override in your class"
      end

      # check if the ModelObject is valid
      def valid?
        return JSON::Validator.validate(@hash, @@schema)
      end
      
      # return detailed model validation errors
      def validation_errors
        return JSON::Validator.fully_validate(@hash, @@schema)
      end
      
      # convert ModelObject to an openstudio object
      def to_openstudio(openstudio_model)
        
        # return the object if we already have it
        if @openstudio_object
          if @openstudio_object.model == openstudio_model
            return @openstudio_object
          end
        end
        
        @errors = validation_errors
        @warnings = []
        @openstudio_object = nil
        
        # see if an equivalent object is already in the openstudio model
        @openstudio_object = find_existing_openstudio_object(openstudio_model)
        if @openstudio_object
          return @openstudio_object
        end
        
        # create and return the object
        @openstudio_object = create_openstudio_object(openstudio_model)
        
        return @openstudio_object
      end
      
      
      # find an equivalent existing object in the openstudio model, return nil if not found
      def find_existing_openstudio_object(openstudio_model)
        raise "find_existing_openstudio_object not implemented for ModelObject, override in your class"
      end
      
      # create a new object in the openstudio model, return new object
      def create_openstudio_object(openstudio_model)
        raise "create_openstudio_object not implemented for ModelObject, override in your class"
      end
      
    end # ModelObject
  end # EnergyModel
end # Ladybug
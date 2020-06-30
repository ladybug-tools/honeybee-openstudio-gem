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

require 'openstudio/extension'

# NOTE: This file has been derived from one within the openStudio-extension gem
# The properties here are a standard part of openstudio extensions

module FromHoneybee
  class Extension < OpenStudio::Extension::Extension
    @@schema = nil
    @@standards = nil

    # Override parent class
    def initialize
      super

      # Note that the root_dir is only meaningful when the gem is in a github repository
      # When installed as a Ruby gem, the highest directory within the gem is the lib_dir
      @root_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..'))
      @lib_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..'))

      @instance_lock = Mutex.new
      @@schema ||= schema
      @@standards ||= standards
    end

    # Return the absolute path of the measures or nil if there is none.
    # Can be used when configuring OSWs
    def measures_dir
      File.absolute_path(File.join(@lib_dir, 'measures'))
    end

    # Relevant files such as the openapi JSON schema files for the honeybee model.
    # Return the absolute path of the files or nil if there is none.
    # Used when configuring OSWs
    def files_dir
      File.absolute_path(File.join(@lib_dir, 'files'))
    end

    # Doc templates are common files like copyright files which are used to update measures
    # Doc templates will only be applied when the gem is a part of a repository
    # Return the absolute path of the doc templates dir or nil if there is none
    def doc_templates_dir
      File.absolute_path(File.join(@root_dir, 'doc_templates'))
    end

    # return path to the model schema file
    def schema_file
      File.join(@lib_dir, 'from_honeybee', '_defaults', 'model.json')
    end

    # return path to the model standards file
    def standards_file
      File.join(@lib_dir, 'from_honeybee', '_defaults', 'energy_default.json')
    end

    # return the model schema
    def schema
      @instance_lock.synchronize do
        if @@schema.nil?
          File.open(schema_file, 'r') do |f|
            @@schema = JSON.parse(f.read, symbolize_names: true)
          end
        end
      end

      @@schema
    end

    # return the JSON of default standards
    def standards
      @instance_lock.synchronize do
        if @@standards.nil?
          File.open(standards_file, 'r') do |f|
            @@standards = JSON.parse(f.read, symbolize_names: true)
          end
        end
      end

      @@standards
    end

    # check if the model schema is valid
    def schema_valid?
      if Gem.loaded_specs.has_key?("json-schema")
        require 'json-schema'
        metaschema = JSON::Validator.validator_for_name('draft6').metaschema
        JSON::Validator.validate(metaschema, @@schema)
      end
    end

    # return detailed schema validation errors
    def schema_validation_errors
      if Gem.loaded_specs.has_key?("json-schema")
        metaschema = JSON::Validator.validator_for_name('draft6').metaschema
        JSON::Validator.fully_validate(metaschema, @@schema)
      end
    end
  end
end

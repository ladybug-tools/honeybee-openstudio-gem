require 'openstudio/extension'

require 'json'

module Ladybug
  module EnergyModel
    class Extension < OpenStudio::Extension::Extension
    
      # Override parent class
      def initialize
        super

        @root_dir = File.absolute_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
        
        @instance_lock = Mutex.new
        @schema
      end
      
      # Return the absolute path of the measures or nil if there is none, can be used when configuring OSWs
      def measures_dir
        return File.absolute_path(File.join(@root_dir, 'lib/measures/'))
      end
      
      # Relevant files such as weather data, design days, etc.
      # Return the absolute path of the files or nil if there is none, used when configuring OSWs
      def files_dir
        return File.absolute_path(File.join(@root_dir, 'lib/files/'))
      end
      
      # Doc templates are common files like copyright files which are used to update measures and other code
      # Doc templates will only be applied to measures in the current repository
      # Return the absolute path of the doc templates dir or nil if there is none
      def doc_templates_dir
        return File.absolute_path(File.join(@root_dir, 'doc_templates'))
      end
      
      # return path to schema file
      def schema_file
        return File.join(files_dir, 'schema/openapi.json')
      end
      
      # return schema
      def schema
        @instance_lock.synchronize do
          if @schema.nil?
            File.open(schema_file, 'r') do |file|
              @schema = JSON::parse(file.read, {symbolize_names: true})
            end
          end
        end
        
        return @schema
      end
      
      # check if the schema is valid
      def schema_valid?
        metaschema = JSON::Validator.validator_for_name("draft4").metaschema
        return JSON::Validator.validate(metaschema, @schema)
      end
      
      # return detailed schema validation errors
      def schema_validation_errors
        metaschema = JSON::Validator.validator_for_name("draft4").metaschema
        return JSON::Validator.fully_validate(metaschema, @schema)
      end
      
    end
  end
end

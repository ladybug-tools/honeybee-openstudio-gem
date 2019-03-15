require 'ladybug/energy_model/extension'

require 'json-schema'
require 'json'

module Ladybug
  module EnergyModel
    class Model
    
      # Read Ladybug Energy Model JSON from disk
      def initialize(file)
        # initialize class variable @@extension only once
        @@extension ||= Extension.new
        @@schema ||= @@extension.schema

        @file = file
        @model = nil
        File.open(File.join(file), 'r') do |f|
          @model = JSON::parse(f.read, {symbolize_names: true})
        end
        
        @model_type = @model[:type]
        raise 'Unknown model type' if @model_type.nil?
      end
      
      # check if the model is valid
      def valid?
        return JSON::Validator.validate(@model, @@schema, {:fragment => "#/components/schemas/#{@model_type}"})
      end
      
      # return detailed model validation errors
      def validation_errors
        return JSON::Validator.fully_validate(@model, @@schema, {:fragment => "#/components/schemas/#{@model_type}"})
      end
      
      
    end
  end
end

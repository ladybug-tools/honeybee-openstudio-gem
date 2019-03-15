require_relative '../spec_helper'

RSpec.describe Ladybug::EnergyModel do
  it 'has a version number' do
    expect(Ladybug::EnergyModel::VERSION).not_to be nil
  end

  it 'has a measures directory' do
    extension = Ladybug::EnergyModel::Extension.new
    expect(File.exist?(extension.measures_dir)).to be true
  end
  
  it 'has a files directory' do
    extension = Ladybug::EnergyModel::Extension.new
    expect(File.exist?(extension.files_dir)).to be true
  end
  
  it 'has a valid schema' do
    extension = Ladybug::EnergyModel::Extension.new
    expect(extension.schema.nil?).to be false
    expect(extension.schema_valid?).to be true
    expect(extension.schema_validation_errors.empty?).to be true
  end
  
  it 'can load and validate example model' do
    file = File.join(File.dirname(__FILE__), '../files/example_model.json')
    model = Ladybug::EnergyModel::Model.new(file)
    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true
  end
 
  it 'can load and validate example face by face model' do
    file = File.join(File.dirname(__FILE__), '../files/example_face_by_face_model.json')
    model = Ladybug::EnergyModel::Model.new(file)
    expect(model.valid?).to be true
    expect(model.validation_errors.empty?).to be true    
  end

end

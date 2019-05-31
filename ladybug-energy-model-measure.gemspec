
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ladybug/energy_model/version'

Gem::Specification.new do |spec|
  spec.name          = 'ladybug-energy-model-measure'
  spec.version       = Ladybug::EnergyModel::VERSION
  spec.authors       = ['Tanushree Charan', 'Dan Macumber', 'Mostapha Sadeghipour Roudsari', 'Chris Mackey']
  spec.email         = ['']

  spec.summary       = 'Library and measures for converting Ladybug Energy Model JSON to OpenStudio'
  spec.description   = 'Library and measures for converting Ladybug Energy Model JSON to OpenStudio'
  spec.homepage      = 'https://github.com/ladybug-tools-in2/energy-model-measure'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '12.3.1'
  spec.add_development_dependency 'rspec', '3.7.0'
  spec.add_development_dependency 'rubocop', '~> 0.54.0'

  spec.add_dependency 'openstudio-extension', '~> 0.1.0'
  spec.add_dependency 'openstudio-standards', '~> 0.2.7'
  spec.add_dependency 'json-schema'
  spec.add_dependency 'json_pure'
  spec.add_dependency 'public_suffix', '~> 3.0.3'
end

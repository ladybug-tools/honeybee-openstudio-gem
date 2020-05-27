
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'from_honeybee/version'

Gem::Specification.new do |spec|
  spec.name          = 'honeybee-openstudio'
  spec.version       = FromHoneybee::VERSION
  spec.authors       = ['Tanushree Charan', 'Dan Macumber', 'Chris Mackey', 'Mostapha Sadeghipour Roudsari']
  spec.email         = ['tanushree.charan@nrel.gov', 'chris@ladybug.tools']

  spec.summary       = 'Gem for translating between Honeybee JSON and OpenStudio Model.'
  spec.description   = 'Library and measures for translating between Honeybee JSON schema and OpenStudio Model schema (OSM).'
  spec.homepage      = 'https://github.com/ladybug-tools/honeybee-openstudio-gem'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '12.3.3'
  spec.add_development_dependency 'rspec', '3.7.0'
  spec.add_development_dependency 'rubocop', '~> 0.54.0'

  spec.add_dependency 'json-schema'
  spec.add_dependency 'json_pure'
  spec.add_dependency 'openstudio-extension', '0.1.6'
  spec.add_dependency 'openstudio-standards', '~> 0.2.7'
  spec.add_dependency 'public_suffix', '~> 3.1.1'
end

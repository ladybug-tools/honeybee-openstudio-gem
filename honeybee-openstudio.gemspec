
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'honeybee-openstudio'
  spec.version       = "0.0.0"
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

  if /^2.7/.match(RUBY_VERSION)
    spec.required_ruby_version = "~> 2.7.0"

    spec.add_development_dependency "bundler",        "~> 2.1"
    spec.add_development_dependency "public_suffix",  "~> 3.1.1"
    spec.add_development_dependency "json-schema",    "~> 2.8.1"
    spec.add_development_dependency "rake",           "~> 13.0"
    spec.add_development_dependency "rspec",          "~> 3.9"
    spec.add_development_dependency "rubocop",        "~> 1.15.0"
  end

  spec.add_dependency 'json_pure'
  spec.add_dependency 'openstudio-extension', '0.4.3'
  spec.add_dependency 'openstudio-standards', '~> 0.2.14'
end

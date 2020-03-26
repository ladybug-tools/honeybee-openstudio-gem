source 'http://rubygems.org'

# Specify your gem's dependencies
gemspec

if File.exist?('../OpenStudio-extension-gem')
  gem 'openstudio-extension', path: '../OpenStudio-extension-gem'
else
  gem 'openstudio-extension', github: 'NREL/OpenStudio-extension-gem', tag: 'v0.1.4'
end

# this code appears to be outdated and so it's commented out for now
# simplecov has an unneccesary dependency on native json gem, use fork that does not require this
# gem 'simplecov', github: 'NREL/simplecov'

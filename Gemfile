source 'http://rubygems.org'

# Specify your gem's dependencies
gemspec

# get the openstudio-extension gem
if File.exist?('../OpenStudio-extension-gem')  # local development copy
  gem 'openstudio-extension', path: '../OpenStudio-extension-gem'
else  # get it from rubygems.org
  gem 'openstudio-extension', '0.7.1'
end

# coveralls gem is used to generate coverage reports through CI
gem 'coveralls_reborn', require: false

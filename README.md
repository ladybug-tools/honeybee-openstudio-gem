# energy-model-measure

Library and measures for converting Honeybee JSONs to/from OpenStudio.


## Local Development
1. Clone this repo locally
```
git clone git@github.com:ladybug-tools-in2/energy-model-measure

# or

git clone https://github.com/ladybug-tools-in2/energy-model-measure
```

2. Install dependencies:
First install the OpenStudio Extension Gem following the
[installation instructions on the gem's github](https://github.com/NREL/openstudio-extension-gem#installation)
This will involve both the installation of OpenStudio and Ruby.
Then, you must install the OpenStudio Extension Gem itself with:
```
gem install openstudio-extension
```
Then, the specific dependencies of this measure can be installed by running:
```
cd energy-model-measure
bundle update
```

3. Run Core Library Tests:
```
cd energy-model-measure
rake
```
coverage report will be output to `energy-model-measure/coverage/index.html`

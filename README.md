[![Build Status](https://travis-ci.org/ladybug-tools-in2/energy-model-measure.svg?branch=master)](https://travis-ci.org/ladybug-tools-in2/energy-model-measure)

# energy-model-measure

Library and measures for converting Honeybee JSONs to/from OpenStudio.


## Run the measures of this repo using OpenStudio CLI

Running the measures using OpenStudio CLI requires no installation other than cloning
this repo and installing OpenStudio.

1. Write out an OpenStudio Workflow (osw) JSON that passes honeybee model and simulation
parameter JSON files to the measures. Here is a sample where the items in parentheses
should be replaced with specific file paths:

```
{ 
    "measure_paths": [(PATH TO THIS REPOSITORY)/lib/measures"], 
    "steps": [
        {
            "arguments": {"model_json": (PATH TO MODEL JSON)}, 
            "measure_dir_name": "from_honeybee_model"
        }, 
        {
            "arguments": {"simulation_parameter_json": (PATH TO SIMULATION PARAMETER JSON)}, 
            "measure_dir_name": "from_honeybee_simulation_parameter"
        }
    ]
}
```

2. Call the OpenStudio CLI from command line, making sure to pass this repository's
lib folder to the CLI using the `-I` (or `--include`) option. Here is a sample
where the items in parentheses should be replaced with specific file paths:

```
"(OPENSTUDIO INSTALLATION PATH)/bin/openstudio.exe" -I (PATH TO THIS REPOSITORY)/lib run -m -w (PATH TO OSW FILE)

```


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
bundle exec rake
```

4. Run Measure Tests:
```
cd energy-model-measure/lib/measures/from_honeybee_model/tests/
bundle exec ruby from_honeybee_model_test.rb

cd energy-model-measure/lib/measures/from_honeybee_simulation_parameter/tests/
bundle exec ruby from_honeybee_simulation_parameter_test.rb
```

coverage report will be output to `energy-model-measure/coverage/index.html`

5. Update doc_templates:
```
cd energy-model-measure
bundle exec rake openstudio:update_copyright
```

6. See all available rake tasks:
```
cd energy-model-measure
bundle exec rake -T
```

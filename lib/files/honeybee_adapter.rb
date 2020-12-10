# *******************************************************************************
# Honeybee OpenStudio Gem, Copyright (c) 2020, Alliance for Sustainable
# Energy, LLC, Ladybug Tools LLC and other contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

require 'openstudio/workflow/adapters/output_adapter'

# Local file based workflow
class HoneybeeAdapter < OpenStudio::Workflow::OutputAdapters
  def initialize(options = {})
    puts "viiiiiiiiiiiiizzzzzzzzz!"
    STDOUT.flush
    super
  end

  # Write to the filesystem that the process has started
  #
  def communicate_started
    File.open("#{@options[:output_directory]}/started.job", 'w') do |f|
      f << "Started Workflow #{::Time.now}"
      # make sure data is written to the disk one way or the other
      begin
        f.fsync
      rescue
        f.flush
      end
    end
  end

  # Write to the filesystem that the process has completed
  #
  def communicate_complete
    File.open("#{@options[:output_directory]}/finished.job", 'w') do |f|
      f << "Finished Workflow #{::Time.now}"
      # make sure data is written to the disk one way or the other
      begin
        f.fsync
      rescue
        f.flush
      end
    end
  end

  # Write to the filesystem that the process has failed
  #
  def communicate_failure
    File.open("#{@options[:output_directory]}/failed.job", 'w') do |f|
      f << "Failed Workflow #{::Time.now}"
      # make sure data is written to the disk one way or the other
      begin
        f.fsync
      rescue
        f.flush
      end
    end
  end

  # Do nothing on a state transition
  #
  def communicate_transition(_ = nil, _ = nil, _ = nil)
  end

  # Do nothing on EnergyPlus stdout
  #
  def communicate_energyplus_stdout(line, options = {})
    puts "EnergyPlus: #{line}"
  end

  # Do nothing on Measure result
  #
  def communicate_measure_result(result, options = {})
    step_result = result.stepResult
    initial_condition = result.stepInitialCondition
    final_condition = result.stepFinalCondition
    errors = result.stepErrors
    warnings = result.stepWarnings
    infos = result.stepInfo

    # Mirrors WorkflowStepResult::string
    tab = 'Honeybee '
    puts "#{tab}Result: #{step_result.get.valueName}" if !step_result.empty?
    puts "#{tab}Initial Condition: #{initial_condition.get}" if !initial_condition.empty?
    puts "#{tab}Final Condition: #{final_condition.get}" if !final_condition.empty?
    errors.each { |error| puts "#{tab}Error: #{error}" }
    warnings.each { |warning| puts "#{tab}Warn: #{warning}" }
    infos.each { |info| puts "#{tab}Info: #{info}" }
  end

  # Write the measure attributes to the filesystem
  #
  def communicate_measure_attributes(measure_attributes, _ = nil)
    attributes_file = "#{@options[:output_directory]}/measure_attributes.json"
    FileUtils.rm_f(attributes_file) if File.exist?(attributes_file)
    File.open(attributes_file, 'w') do |f|
      f << JSON.pretty_generate(measure_attributes)
      # make sure data is written to the disk one way or the other
      begin
        f.fsync
      rescue
        f.flush
      end
    end
  end

  # Write the objective function results to the filesystem
  #
  def communicate_objective_function(objectives, _ = nil)
    obj_fun_file = "#{@options[:output_directory]}/objectives.json"
    FileUtils.rm_f(obj_fun_file) if File.exist?(obj_fun_file)
    File.open(obj_fun_file, 'w') do |f|
      f << JSON.pretty_generate(objectives)
      # make sure data is written to the disk one way or the other
      begin
        f.fsync
      rescue
        f.flush
      end
    end
  end

  # Write the results of the workflow to the filesystem
  #
  def communicate_results(directory, results)
    zip_results(directory)

    if results.is_a? Hash
      # DLM: don't we want this in the results zip?
      # DLM: deprecate in favor of out.osw
      File.open("#{@options[:output_directory]}/data_point_out.json", 'w') do |f|
        f << JSON.pretty_generate(results)
        # make sure data is written to the disk one way or the other
        begin
          f.fsync
        rescue
          f.flush
        end
      end
    else
      #puts "Unknown datapoint result type. Please handle #{results.class}"
    end
  end
end


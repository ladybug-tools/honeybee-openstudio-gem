# *******************************************************************************
# Honeybee Energy Model Measure, Copyright (c) 2020, Alliance for Sustainable 
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
require_relative '../spec_helper'

RSpec.describe FromHoneybee do
  it 'has a version number' do
    expect(FromHoneybee::VERSION).not_to be nil
  end

  it 'has a measures directory' do
    extension = FromHoneybee::Extension.new
    expect(File.exist?(extension.measures_dir)).to be true
  end

  it 'has a files directory' do
    extension = FromHoneybee::Extension.new
    expect(File.exist?(extension.files_dir)).to be true
  end

  # TODO: add assertions about properties
  it 'can load construction set complete' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/construction_set/constructionset_complete.json')
    constr_set_1 = FromHoneybee::ConstructionSetAbridged.read_from_disk(file)
    object1 = constr_set_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

  it 'can load construction set partial' do
    openstudio_model = OpenStudio::Model::Model.new
    file = File.join(File.dirname(__FILE__), '../files/construction_set/constructionset_partial_exterior.json')
    constr_set_1 = FromHoneybee::ConstructionSetAbridged.read_from_disk(file)
    object1 = constr_set_1.to_openstudio(openstudio_model)
    expect(object1).not_to be nil
  end

end
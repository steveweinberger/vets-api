# frozen_string_literal: true

# example run:
#   NOCOVERAGE=y bundle exec ruby spec/profile_driver.rb modules/vaos/spec/models/v2/appointment_form_spec.rb:30 \
#   modules/vaos/spec/models/v2/appointment_form_spec.rb:11
#
# to see the flamegraph use speedscope (install speedscope via npm: npm install -g speedscope)
#    speedscope tmp/stackprof.json

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'json'
require 'stackprof'
require 'rspec'
require 'pry'
require 'rspec/mocks'
require_relative 'rails_helper'

profile = StackProf.run(mode: :wall, raw: true) do
  RSpec::Core::Runner.run(ARGV, $stderr, $stdout)
end

File.write('tmp/stackprof.json', JSON.generate(profile))

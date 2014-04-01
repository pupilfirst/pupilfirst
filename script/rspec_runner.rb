#!/usr/bin/env ruby

# Suppress zeus' whining about how it won't use your RAILS_ENV
ENV.delete('RAILS_ENV')

# Zeus 0.13.2 parses options badly. RubyMine will invoke this file like this:
# rspec_runner.rb spec/my_cool_file.rb --require teamcity/spec/runner/formatter/teamcity/formatter --format Spec::Runner::Formatter::TeamcityFormatter
#
# ...but Zeus will parse those options thinking --require is meant for it, and die.
# If the test file is moved to the end, it dies less.
ARGV.push(ARGV.shift)

# Add rspec to the beginning of the commands sent to Zeus
ARGV.unshift 'rspec'

require 'rubygems'
require 'zeus'
load Gem.bin_path('zeus', 'zeus')

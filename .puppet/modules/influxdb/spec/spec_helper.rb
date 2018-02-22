require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

# Include code coverage report for all our specs
at_exit { RSpec::Puppet::Coverage.report! }

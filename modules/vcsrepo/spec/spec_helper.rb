require 'puppetlabs_spec_helper/module_spec_helper'
require 'support/filesystem_helpers'
require 'support/fixture_helpers'

# SimpleCov does not run on Ruby 1.8.7
unless RUBY_VERSION.to_f < 1.9
  require 'simplecov'
  SimpleCov.start do
    add_filter '/spec/'
  end
end

RSpec.configure do |c|
  c.include FilesystemHelpers
  c.include FixtureHelpers
end

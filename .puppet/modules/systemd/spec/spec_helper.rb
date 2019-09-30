require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts


add_custom_fact :systemd_internal_services, YAML.load(File.read(File.expand_path('../default_module_facts.yaml', __FILE__)))

RSpec.configure do |c|
  c.include PuppetlabsSpec::Files

  # Useless backtrace noise
  backtrace_exclusion_patterns = [
    /spec_helper/,
    /gems/
  ]

  if c.respond_to?(:backtrace_exclusion_patterns)
    c.backtrace_exclusion_patterns = backtrace_exclusion_patterns
  elsif c.respond_to?(:backtrace_clean_patterns)
    c.backtrace_clean_patterns = backtrace_exclusion_patterns
  end

  c.before :each do
    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}

    c.strict_variables = Gem::Version.new(Puppet.version) >= Gem::Version.new('3.5')
    Puppet.features.stubs(:root?).returns(true)
  end

  c.after :each do
    PuppetlabsSpec::Files.cleanup
  end
end

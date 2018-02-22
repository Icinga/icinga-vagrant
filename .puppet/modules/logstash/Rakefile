require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec/core/rake_task'

exclude_paths = [
  'pkg/**/*',
  'vendor/**/*',
  'spec/**/*'
]

log_format = '%{path}:%{linenumber}:%{check}:%{KIND}:%{message}'

PuppetLint::RakeTask.new :lint do |config|
  config.disable_checks = ['80chars']
  config.fail_on_warnings = true
  config.with_context = true
  config.ignore_paths = exclude_paths
  config.log_format = log_format
end

RSpec::Core::RakeTask.new(:spec_verbose) do |t|
  t.pattern = 'spec/{classes,defines,lib,reports}/**/*_spec.rb'
  t.rspec_opts = [
    '--format documentation',
    '--require "ci/reporter/rspec"',
    '--format CI::Reporter::RSpecFormatter',
    '--color'
  ]
end

# RSpec::Core::RakeTask.new(:henry) do |t|
#   t.pattern = 'spec/acceptance/**/*_spec.rb'
#   t.rspec_opts = '--format progress --color'
# end

# RSpec::Core::RakeTask.new(:beaker_verbose) do |t|
#   t.pattern = 'spec/acceptance/**/*_spec.rb'
#   t.rspec_opts = [
#     '--format documentation',
#     '--color'
#   ]
# end

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_selector_inside_resource')
PuppetLint.configuration.send('disable_only_variable_string')

exclude_paths = %w(
  spec/**/*
  serverspec/**/*
  pkg/**/*
  examples/**/*
  vendor/**/*
  .vendor/**/*
)

PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = exclude_paths
end

PuppetSyntax.exclude_paths = exclude_paths

desc 'Run validate, parallel_spec, lint'
task test: %w(metadata_lint validate parallel_spec lint)

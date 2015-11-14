require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

# These two gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
end

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

Rake::Task[:lint].clear
PuppetLint::RakeTask.new :lint do |config|
  # Pattern of files to ignore
  config.ignore_paths = exclude_paths

  # List of checks to disable
  config.disable_checks = [
    '80chars',
    'autoloader_layout',
    'class_parameter_defaults',
    'class_inherits_from_params_class'
  ]

  # Should the task fail if there were any warnings, defaults to false
  config.fail_on_warnings = true

  # Print out the context for the problem, defaults to false
  config.with_context = true

  # Format string for puppet-lint's output (see the puppet-lint help output
  # for details
  config.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"

  # Compare module layout relative to the module root
  # config.relative = true
end

PuppetSyntax.exclude_paths = exclude_paths

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end

desc "Run syntax, lint, and spec tests."
task :test => [
  :syntax,
  :lint,
  :spec,
]

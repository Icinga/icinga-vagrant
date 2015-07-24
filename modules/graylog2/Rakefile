require 'rake'
require 'rspec/core/rake_task'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_blacksmith/rake_tasks'
require 'puppetlabs_spec_helper/rake_tasks'


PuppetLint.configuration.relative = true
PuppetLint.configuration.fail_on_warnings = true
PuppetLint.configuration.send('disable_class_inherits_from_params_class')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_arrow_alignment')
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"

exclude_paths = [
  "modules/**/*",
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths

task :default => [:syntax, :lint, :spec]

task :build => :default do
  # There is no way to exclude files with the module tools. So we need this
  # gross hack.
  sh "rm -rf build && git clone $PWD build"
  sh "cd build && rm -rf development Gemfile Vagrantfile"
  sh "cd build && bundle exec puppet module build $PWD"
  sh "mkdir -p pkg && mv build/pkg/*.gz pkg/ && rm -rf build"
end

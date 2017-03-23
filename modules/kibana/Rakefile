# frozen_string_literal: true
require 'rubygems'
require 'bundler/setup'

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet/version'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'metadata-json-lint/rake_task'
require 'rubocop/rake_task'
require 'puppet-strings'
require 'puppet-strings/tasks'

if Puppet.version.to_f >= 4.9
  require 'semantic_puppet'
elsif Puppet.version.to_f >= 3.6 && Puppet.version.to_f < 4.9
  require 'puppet/vendor/semantic/lib/semantic'
end

# These gems aren't always present, for instance
# on Travis with --without development
begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

RuboCop::RakeTask.new

exclude_paths = [
  'coverage/**/*',
  'doc/**/*',
  'pkg/**/*',
  'vendor/**/*',
  'spec/**/*'
]

Rake::Task[:lint].clear

PuppetLint.configuration.relative = true
PuppetLint.configuration.disable_80chars
PuppetLint.configuration.disable_class_inherits_from_params_class
PuppetLint.configuration.disable_class_parameter_defaults
PuppetLint.configuration.fail_on_warnings = true

PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = exclude_paths
end

PuppetSyntax.exclude_paths = exclude_paths

task :beaker => :spec_prep
task :spec_standalone => :spec_prep

namespace :docs do
  desc 'Evaluation documentation coverage'
  task :coverage do
    require 'puppet-strings/yard'

    PuppetStrings::Yard.setup!
    YARD::CLI::Yardoc.run(
      %w(
        manifests/**/*.pp
      )
    )
  end
end

desc 'Run syntax, lint, and spec tests.'
task :test => [
  :metadata_lint,
  :syntax,
  :lint,
  :rubocop,
  :spec_standalone,
  'docs:coverage'
]

desc 'remove outdated module fixtures'
task :spec_prune do
  mods = 'spec/fixtures/modules'
  fixtures = YAML.load_file '.fixtures.yml'
  fixtures['fixtures']['forge_modules'].each do |mod, params|
    next unless params.is_a? Hash \
      and params.key? 'ref' \
      and File.exist? "#{mods}/#{mod}"

    metadata = JSON.parse(File.read("#{mods}/#{mod}/metadata.json"))
    FileUtils.rm_rf "#{mods}/#{mod}" unless metadata['version'] == params['ref']
  end
end
task :spec_prep => [:spec_prune]

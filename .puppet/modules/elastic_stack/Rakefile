require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-syntax/tasks/puppet-syntax'

desc 'Run the test suite.'
task :test => [
  :rubocop,
  :syntax,
  :validate,
  :lint,
  :spec
]

require 'rubygems'
require 'bundler/setup'

Bundler.require :default

require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'

begin
  require 'kitchen/rake_tasks'
rescue LoadError
end

task :default do
  sh %{rake -T}
end

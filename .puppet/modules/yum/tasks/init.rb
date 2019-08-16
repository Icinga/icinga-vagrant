#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'open3'
require 'puppet'

def yum(action, quiet)
  cmd = ['yum', '-y']
  cmd << '-q' unless quiet == false || quiet.nil?
  cmd << action

  stdout, stderr, status = Open3.capture3(*cmd)
  raise Puppet::Error, stderr unless status.success?
  { status: stdout.strip }
end

params = JSON.parse(STDIN.read)
action = params['action']
quiet = params['quiet']

begin
  result = yum(action, quiet)
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure', error: e.message }.to_json)
  exit 1
end

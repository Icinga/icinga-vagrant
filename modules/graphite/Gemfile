source ENV['GEM_SOURCE'] || "https://rubygems.org"

def location_for(place, version = nil)
  if place =~ /^((?:git|https?)[:@][^#]*)#(.*)/
    [version, { :git => $1, :branch => $2, :require => false }].compact
  elsif place =~ /^file:\/\/(.*)/
    ['>= 0', { :path => File.expand_path($1), :require => false }]
  else
    [place, version, { :require => false }].compact
  end
end

gem 'puppet', *location_for(ENV['PUPPET_GEM_VERSION'] || '~> 4')
gem 'facter', *location_for(ENV['FACTER_GEM_VERSION'] || '~> 2')
gem 'puppetlabs_spec_helper', '>= 0.1.0', :require => false
gem 'puppet-lint', '>= 0.3.2',            :require => false
gem 'rspec-puppet', '>= 2.3.2',           :require => false
gem 'rspec-puppet-facts',                 :require => false
gem 'metadata-json-lint',                 :require => false
gem 'rake', '< 11.0.0' # rubi <1.9 versus rake 11.0.0 workaround

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

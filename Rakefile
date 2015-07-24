require 'puppetlabs_spec_helper/rake_tasks'
require 'rake'

desc "Run beaker-rspec and beaker tests"
task 'beaker:test:all',[:host,:type] => ["rake:beaker:rspec:test", "rake:beaker:test"] do |t,args|
end

desc "Run beaker-rspec tests"
task 'beaker:rspec:test',[:host,:type] => [:set_beaker_variables] do |t,args|
  Rake::Task['beaker-rspec:test'].invoke(args)
end

desc "Run beaker tests"
task 'beaker:test',[:host,:type] => [:set_beaker_variables] do |t,args|
  sh(build_beaker_command args)
end

desc "Run beaker rspec tasks against pe"
RSpec::Core::RakeTask.new('beaker-rspec:test',[:host,:type]=>:set_beaker_variables) do |t,args|
  t.pattern     = 'spec/acceptance'
  t.rspec_opts  = '--color'
  t.verbose     = true
end

desc "Run beaker and beaker-rspec tasks"
task 'beaker:test:pe',:host do |t,args|
  args.with_defaults(:type=> 'pe')
  Rake::Task['beaker:test'].invoke(args[:host],args[:type])
end

task 'beaker:test:git',:host do |t,args|
  args.with_defaults({:type=> 'git'})
  Rake::Task['beaker:test'].invoke(args[:host],args[:type])
end

task :set_beaker_variables do |t,args|
  puts 'Setting environment variables for testing'
  if args[:host]
    ENV['BEAKER_set'] = args[:host]
    puts "Host to test #{ENV['BEAKER_set']}"
  end
  ENV['BEAKER_IS_PE'] = args[:type] == 'pe'? "true": "false"
  if ENV['BEAKER_setfile']
    @hosts_config = ENV['BEAKER_setfile']
  end
  if File.exists?(check_args_for_keyfile(args.extras))
    ENV['BEAKER_keyfile'] = check_args_for_keyfile(args.extras)
  end
end

def build_beaker_command(args)
  cmd = ["beaker"]
  cmd << "--type #{args[:type]}" unless !args[:type]
  if File.exists?("./.beaker-#{args[:type]}.cfg")
    cmd << "--options-file ./.beaker-#{args[:type]}.cfg"
  end
  if File.exists?(@hosts_config)
    cmd << "--hosts #{@hosts_config}"
  end
  if File.exists?('./spec/acceptance/beaker_helper.rb')
    cmd << "--pre-suite ./spec/acceptance/beaker_helper.rb"
  end
  if File.exists?("./spec/acceptance/beaker")
    cmd << "--tests ./spec/acceptance/beaker"
  end
  if File.exists?(check_args_for_keyfile(args.extras))
    cmd << "--keyfile #{check_args_for_keyfile(args.extras)}"
  end
  cmd.join(" ")
end

def check_args_for_keyfile(extra_args)
  keyfile = ''
  extra_args.each do |a|
    keyfile = a unless (`ssh-keygen -l -f #{a}`.gsub(/\n/,"").match(/is not a .*key file/))
  end
  return keyfile
end

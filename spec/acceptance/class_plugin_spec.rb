# coding: utf-8
require 'spec_helper_acceptance'

describe 'class plugin' do
  def ensure_plugin(present_absent, plugin, extra_args = nil)
    manifest = <<-END
      class { 'logstash':
        status       => 'disabled',
      }

      logstash::plugin { '#{plugin}':
        ensure => #{present_absent},
        #{extra_args if extra_args}
      }
      END
    apply_manifest(manifest, catch_failures: true)
  end

  def installed_plugins
    shell('/opt/logstash/bin/plugin list').stdout
  end

  def remove(plugin)
    shell("/opt/logstash/bin/plugin uninstall #{plugin} || true")
  end

  before(:all) do
    install_logstash_from_local_file
  end

  before(:each) do
    stop_logstash
  end

  unless ENV['TRAVIS_CI']
    # These tests are inexplicably, maddeningly slow under Travis CI.
    context 'when a plugin is not installed' do
      before(:each) do
        remove('logstash-output-csv')
      end

      it 'will not remove it again' do
        log = ensure_plugin('absent', 'logstash-output-csv').stdout
        expect(log).to_not contain('remove-logstash-output-csv')
      end

      it 'can install it from rubygems' do
        ensure_plugin('present', 'logstash-output-csv')
        expect(installed_plugins).to contain('logstash-output-csv')
      end
    end

    context 'when a plugin is installed' do
      before(:each) do
        expect(installed_plugins).to contain('logstash-input-file')
      end

      it 'will not install it again' do
        log = ensure_plugin('present', 'logstash-input-file').stdout
        expect(log).to_not contain('install-logstash-input-file')
      end

      it 'can remove it' do
        ensure_plugin('absent', 'logstash-input-file')
        expect(installed_plugins).not_to contain('logstash-input-file')
      end
    end
  end

  it 'can install a plugin from a local gem' do
    plugin = 'logstash-output-cowsay'
    source = "/tmp/#{plugin}-0.1.0.gem"
    ensure_plugin('present', plugin, "source => '#{source}'")
    expect(installed_plugins).to contain(plugin)
  end

  it 'can install a plugin from a "puppet://" url' do
    plugin = 'logstash-output-cowthink'
    source = "puppet:///modules/logstash/#{plugin}-0.1.0.gem"
    ensure_plugin('present', plugin, "source => '#{source}'")
    expect(installed_plugins).to contain(plugin)
  end
end

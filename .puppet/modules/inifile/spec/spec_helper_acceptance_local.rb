# frozen_string_literal: true

def setup_test_directory
  basedir = case os[:family]
            when 'windows'
              'C:/inifile_test'
            else
              '/tmp/inifile_test'
            end
  pp = <<-MANIFEST
    file { '#{basedir}':
      ensure  => directory,
      force   => true,
      purge   => true,
      recurse => true,
    }
    file { '#{basedir}/file':
      content => "file exists\n",
      force   => true,
    }
  MANIFEST
  apply_manifest(pp)
  basedir
end

def setup_puppet_config_file
  config_path = case os[:family]
                when 'windows'
                  'C:\ProgramData\PuppetLabs\puppet\etc\puppet.conf'
                else
                  '/etc/puppetlabs/puppet/puppet.conf'
                end
  config_pp = <<-MANIFEST
      file { '#{config_path}':
        content => "[main]\nshow_diff = true",
        force   => true,
      }
  MANIFEST
  apply_manifest(config_pp)
end

# frozen_string_literal: true

def setup_test_directory
  basedir = case os[:family]
            when 'windows'
              'c:/concat_test'
            else
              '/tmp/concat_test'
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

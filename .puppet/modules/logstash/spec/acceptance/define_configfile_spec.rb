require 'spec_helper_acceptance'

describe 'define logstash::configfile' do
  context 'with explicit content' do
    logstash_config = 'input { heartbeat {} }'

    manifest = <<-END
    logstash::configfile { 'heartbeat-input':
      content => '#{logstash_config}'
    }
    END

    before(:context) do
      apply_manifest(manifest, catch_failures: true)
    end

    it 'creates a file with the given content' do
      result = shell('cat /etc/logstash/conf.d/heartbeat-input').stdout
      expect(result).to eq(logstash_config)
    end
  end

  context 'with a template' do
    manifest = <<-END
    logstash::configfile { 'from-template':
      template => 'logstash/configfile-template.erb'
    }
    END

    before(:context) do
      apply_manifest(manifest, catch_failures: true, debug: true)
    end

    it 'creates a config file from the template' do
      result = shell('cat /etc/logstash/conf.d/from-template').stdout
      expect(result).to include('2 + 2 equals 4')
    end
  end

  context 'with a puppet:// url as source parameter' do
    manifest = <<-END
    logstash::configfile { 'null-output':
      source => 'puppet:///modules/logstash/null-output.conf'
    }
    END

    before(:context) do
      apply_manifest(manifest, catch_failures: true)
    end

    it 'places the config file' do
      result = shell('cat /etc/logstash/conf.d/null-output').stdout
      expect(result).to include('Test output configuration with null output.')
    end
  end

  context 'with an explicit path parameter' do
    logstash_config = 'input { heartbeat { message => "right here"} }'
    path = '/tmp/explicit-path.cfg'

    manifest = <<-END
    logstash::configfile { 'heartbeat-input':
      content => '#{logstash_config}',
      path    => '#{path}',
    }
    END

    before(:context) do
      apply_manifest(manifest, catch_failures: true)
    end

    it 'creates a file with the given content at the correct path' do
      result = shell("cat #{path}").stdout
      expect(result).to eq(logstash_config)
    end
  end
end

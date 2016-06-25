# coding: utf-8
require 'spec_helper_acceptance'

describe 'class patternfile' do
  def apply_pattern(pattern_number, extra_logstash_class_args = nil)
    manifest = <<-END
      #{install_logstash_from_local_file_manifest(extra_logstash_class_args)}

      logstash::patternfile { 'pattern':
        source   => 'puppet:///modules/logstash/grok-pattern-#{pattern_number}',
        filename => 'the_only_pattern_file',
      }
      END
    apply_manifest(manifest)
  end

  context 'when declaring a pattern file' do
    before(:context) { apply_pattern(0) }

    describe file '/etc/logstash/patterns/the_only_pattern_file' do
      it { should be_a_file }
      its(:content) { should match(/GROK_PATTERN_0/) }
    end
  end

  context 'with a pattern file in place' do
    before(:each) { apply_pattern(0) }
    restart_message = 'Scheduling refresh of Service[logstash]'

    it 'restarts logstash when a pattern file changes' do
      log = apply_pattern(1).stdout
      expect(log).to include(restart_message)
    end

    it 'does not restart logstash if logstash::restart_on_change is false' do
      log = apply_pattern(1, 'restart_on_change => false').stdout
      expect(log).not_to include(restart_message)
    end
  end
end

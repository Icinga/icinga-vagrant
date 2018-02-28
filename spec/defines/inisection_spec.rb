require 'spec_helper'

describe('icingaweb2::inisection', :type => :define) do
  let(:title) { 'foo' }
  let(:pre_condition) { [
      "class { 'icingaweb2': }"
  ] }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      context "#{os} with valid params" do
        let(:params) { {:target => '/foo/bar', :section_name => 'test', :settings =>  {'setting1' => 'value1', 'setting2' => 'value2'}  } }

        it { is_expected.to contain_concat('/foo/bar') }

        it { is_expected.to contain_concat__fragment('foo-test-01')
          .with_target('/foo/bar')
          .with_order('01')
          .with_content(/\[test\]\nsetting1 = \"value1\"\nsetting2 = \"value2\"\n\n/) }
      end
    end
  end
end

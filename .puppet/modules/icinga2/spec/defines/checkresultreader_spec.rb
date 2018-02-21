require 'spec_helper'

describe('icinga2::object::checkresultreader', :type => :define) do
  let(:title) { 'bar' }
  let(:pre_condition) { [
      "class { 'icinga2': }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end

    context "#{os} with all defaults and target => /bar/baz" do
      let(:params) { {:target =>  '/bar/baz'} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.to contain_concat__fragment('icinga2::object::CheckResultReader::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object CheckResultReader "bar"/) }

      it { is_expected.to contain_concat__fragment('icinga2::object::CheckResultReader::bar-library')
                              .with({'target' => '/bar/baz'})
                              .with_content(/library "compat"/) }

      it { is_expected.to contain_icinga2__object('icinga2::object::CheckResultReader::bar')
                              .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with checkresultreader_name => foo" do
      let(:params) { {:checkresultreader_name => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::CheckResultReader::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object CheckResultReader "foo"/) }
    end


    context "#{os} with spool_dir = /foo/bar" do
      let(:params) { {:spool_dir => '/foo/bar', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::CheckResultReader::bar')
                              .with({ 'target' => '/bar/baz' })
                              .with_content(/spool_dir = "\/foo\/bar"/) }
    end


    context "#{os} with spool_dir = foo/bar (not a valid absolute path)" do
      let(:params) { {:spool_dir => 'foo/bar', :target => '/bar/baz'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end
  end
end


describe('icinga2::object::checkresultreader', :type => :define) do
  let(:facts) { {
      :kernel => 'Windows',
      :architecture => 'x86_64',
      :osfamily => 'Windows',
      :operatingsystem => 'Windows',
      :operatingsystemmajrelease => '2012 R2',
      :path => 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;
               C:\Program Files\Puppet Labs\Puppet\facter\bin;
               C:\Program Files\Puppet Labs\Puppet\hiera\bin;
               C:\Program Files\Puppet Labs\Puppet\mcollective\bin;
               C:\Program Files\Puppet Labs\Puppet\bin;
               C:\Program Files\Puppet Labs\Puppet\sys\ruby\bin;
               C:\Program Files\Puppet Labs\Puppet\sys\tools\bin;
               C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;
               C:\Windows\System32\WindowsPowerShell\v1.0\;
               C:\ProgramData\chocolatey\bin;',
  } }
  let(:title) { 'bar' }
  let(:pre_condition) { [
      "class { 'icinga2': }"
  ] }


  context "Windows 2012 R2 with all defaults and target => C:/bar/baz" do
    let(:params) { {:target =>  'C:/bar/baz'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('icinga2::object::CheckResultReader::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object CheckResultReader "bar"/) }

    it { is_expected.to contain_concat__fragment('icinga2::object::CheckResultReader::bar-library')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/library "compat"/) }

    it { is_expected.to contain_icinga2__object('icinga2::object::CheckResultReader::bar')
                            .that_notifies('Class[icinga2::service]') }
  end


  context "Windows 2012 R2 with checkresultreader_name => foo" do
    let(:params) { {:checkresultreader_name => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::CheckResultReader::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object CheckResultReader "foo"/) }
  end


  context "Windows 2012 R2 with spool_dir = /foo/bar" do
    let(:params) { {:spool_dir => '/foo/bar', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::CheckResultReader::bar')
                            .with({ 'target' => 'C:/bar/baz' })
                            .with_content(/spool_dir = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with spool_dir = foo/bar (not a valid absolute path)" do
    let(:params) { {:spool_dir => 'foo/bar', :target => 'C:/bar/baz'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end
end

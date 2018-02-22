require 'spec_helper'

describe('icinga2::object::dependency', :type => :define) do
  let(:title) { 'bar' }
  let(:pre_condition) { [
      "class { 'icinga2': }"
  ] }

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end

    context "#{os} with all defaults and target => /bar/baz" do
      let(:params) { {
          :target =>  '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to contain_concat('/bar/baz') }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object Dependency "bar"/)
                              .without_content(/assign where/)
                              .without_content(/ignore where/) }

      it { is_expected.to contain_icinga2__object('icinga2::object::Dependency::bar')
                              .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with dependency_name => foo" do
      let(:params) { {:dependency_name => 'foo', :target => '/bar/baz'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/object Dependency "foo"/) }
    end


    context "#{os} with parent_host_name => foo" do
      let(:params) { {
          :parent_host_name => 'foo',
          :target => '/bar/baz',
          :child_host_name => 'childfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/parent_host_name = "foo"/) }
    end


    context "#{os} with parent_service_name => foo" do
      let(:params) { {
          :parent_service_name => 'foo',
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/parent_service_name = "foo"/) }
    end


    context "#{os} with child_host_name => foo" do
      let(:params) { {
          :child_host_name => 'foo',
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/child_host_name = "foo"/) }
    end


    context "#{os} with child_service_name => foo" do
      let(:params) { {
          :child_service_name => 'foo',
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/child_service_name = "foo"/) }
    end


    context "#{os} with disable_checks => false" do
      let(:params) { {
          :disable_checks => false,
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/disable_checks = false/) }
    end


    context "#{os} with disable_checks => foo (not a valid boolean)" do
      let(:params) { {
          :disable_checks => 'foo',
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with disable_notifications => false" do
      let(:params) { {
          :disable_notifications => false,
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/disable_notifications = false/) }
    end


    context "#{os} with disable_notifications => foo (not a valid boolean)" do
      let(:params) { {
          :disable_notifications => 'foo',
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with ignore_soft_states => false" do
      let(:params) { {
          :ignore_soft_states => false,
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/ignore_soft_states = false/) }
    end


    context "#{os} with ignore_soft_states => foo (not a valid boolean)" do
      let(:params) { {
          :ignore_soft_states => 'foo',
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with period => foo" do
      let(:params) { {
          :period => 'foo',
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/period = "foo"/) }
    end


    context "#{os} with states => [foo, bar]" do
      let(:params) { {
          :states => ['foo','bar'],
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                              .with({'target' => '/bar/baz'})
                              .with_content(/states = \[ "foo", "bar", \]/) }
    end


    context "#{os} with states => foo (not a valid array)" do
      let(:params) { {
          :states => 'foo',
          :target => '/bar/baz',
          :parent_host_name => 'parentfoo',
          :child_host_name => 'childfoo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
    end
  end
end

describe('icinga2::object::dependency', :type => :define) do
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
    let(:params) { {
        :target =>  'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to contain_concat('C:/bar/baz') }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object Dependency "bar"/)
                            .without_content(/assign where/)
                            .without_content(/ignore where/) }

    it { is_expected.to contain_icinga2__object('icinga2::object::Dependency::bar')
                            .that_notifies('Class[icinga2::service]') }
  end


  context "Windows 2012 R2 with dependency_name => foo" do
    let(:params) { {:dependency_name => 'foo', :target => 'C:/bar/baz'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/object Dependency "foo"/) }
  end


  context "Windows 2012 R2 with parent_host_name => foo" do
    let(:params) { {
        :parent_host_name => 'foo',
        :target => 'C:/bar/baz',
        :child_host_name => 'childfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/parent_host_name = "foo"/) }
  end


  context "Windows 2012 R2 with parent_service_name => foo" do
    let(:params) { {
        :parent_service_name => 'foo',
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/parent_service_name = "foo"/) }
  end


  context "Windows 2012 R2 with child_host_name => foo" do
    let(:params) { {
        :child_host_name => 'foo',
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/child_host_name = "foo"/) }
  end


  context "Windows 2012 R2 with child_service_name => foo" do
    let(:params) { {
        :child_service_name => 'foo',
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/child_service_name = "foo"/) }
  end


  context "Windows 2012 R2 with disable_checks => false" do
    let(:params) { {
        :disable_checks => false,
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/disable_checks = false/) }
  end


  context "Windows 2012 R2 with disable_checks => foo (not a valid boolean)" do
    let(:params) { {
        :disable_checks => 'foo',
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with disable_notifications => false" do
    let(:params) { {
        :disable_notifications => false,
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/disable_notifications = false/) }
  end


  context "Windows 2012 R2 with disable_notifications => foo (not a valid boolean)" do
    let(:params) { {
        :disable_notifications => 'foo',
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with ignore_soft_states => false" do
    let(:params) { {
        :ignore_soft_states => false,
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/ignore_soft_states = false/) }
  end


  context "Windows 2012 R2 with ignore_soft_states => foo (not a valid boolean)" do
    let(:params) { {
        :ignore_soft_states => 'foo',
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with period => foo" do
    let(:params) { {
        :period => 'foo',
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/period = "foo"/) }
  end


  context "Windows 2012 R2 with states => [foo, bar]" do
    let(:params) { {
        :states => ['foo','bar'],
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::Dependency::bar')
                            .with({'target' => 'C:/bar/baz'})
                            .with_content(/states = \[ "foo", "bar", \]/) }
  end


  context "Windows 2012 R2 with states => foo (not a valid array)" do
    let(:params) { {
        :states => 'foo',
        :target => 'C:/bar/baz',
        :parent_host_name => 'parentfoo',
        :child_host_name => 'childfoo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
  end
end

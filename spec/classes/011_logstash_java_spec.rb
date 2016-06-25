require 'spec_helper'

describe 'logstash', :type => 'class' do

  context "install java" do

    ['Debian', 'Ubuntu'].each do |distro|
      context "On #{distro} OS" do
        let :params do {
          :java_install => true
        } end

        let :facts do {
          :operatingsystem => distro,
          :kernel => 'Linux'
        } end

        it { should contain_class('logstash::java') }
        it { should contain_package('openjdk-7-jre-headless') }

      end
    end

    [ 'RedHat', 'CentOS', 'Fedora', 'Scientific', 'Amazon', 'OracleLinux' ].each do |distro|
      context "On #{distro} OS" do
        let :params do {
          :java_install => true
        } end

        let :facts do {
          :operatingsystem => distro,
          :kernel => 'Linux'
        } end

        it { should contain_class('logstash::java') }
        it { should contain_package('java-1.7.0-openjdk') }

      end
    end

    context "On an unknown OS" do

      let :facts do {
        :operatingsystem => 'Windows',
        :kernel => 'Windows'
      } end

      it { expect { should raise_error(Puppet::Error) } }

    end

    context "Custom java package" do

      let :facts do {
        :operatingsystem => 'CentOS',
        :kernel => 'Linux'
      } end

      let :params do {
        :java_install => true,
        :java_package => 'java-1.7.4-openjdk'
      } end

      it { should contain_class('logstash::java') }
      it { should contain_package('java-1.7.4-openjdk') }

    end

  end

end

require 'spec_helper'

describe 'logstash', :type => 'class' do

  context "Repo class" do

    let :facts do {
      :operatingsystem => 'CentOS',
      :kernel => 'Linux',
      :osfamily => 'RedHat'
    } end

    context "Use anchor type for ordering" do

      let :params do {
        :manage_repo => true,
        :repo_version => 1.3
      } end

      it { should contain_class('logstash::repo').that_requires('Anchor[logstash::begin]') }
    end


    context "Use stage type for ordering" do

      let :params do {
        :manage_repo => true,
        :repo_version => 1.3,
        :repo_stage => 'setup'
      } end

      it { should contain_stage('setup') }
      it { should contain_class('logstash::repo').with(:stage => 'setup') }

    end

  end

end

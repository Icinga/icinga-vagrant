require 'spec_helper'

describe 'graylog2::server' do

  let(:default_params) do
    {
      :password_secret    => 'MZAodINWvoN381NjsJvX1ToMfdo0CYO92n3HSQMd1vFKqeJ8nO17it3FW2e1IAv4',
      :root_password_sha2 => '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918'
    }
  end

  [ 'Debian', 'RedHat' ].each do |dist|

    if dist == 'Debian'
      let(:defaults_path) { '/etc/default/graylog-server' }
    end
    if dist == 'RedHat'
      let(:defaults_path) { '/etc/sysconfig/graylog-server' }
    end
    let(:default_facts) do
      {
        :osfamily => dist,
      }
    end


    context 'should work with only mandatory params' do
      let(:facts) do
        {
        }.merge default_facts
      end
      let(:params) do
        {
        }.merge default_params
      end
      it {
        should contain_class('graylog2::server')
      }
      it {
        should contain_package('graylog-server').with_ensure('installed')
      }
      it {
        should contain_file(defaults_path).with_content(/^GRAYLOG_SERVER_JAVA_OPTS="-Xms1g -Xmx1g -XX:NewRatio=1 -XX:PermSize=128m -XX:MaxPermSize=256m -server -XX:\+ResizeTLAB -XX:\+UseConcMarkSweepGC -XX:\+CMSConcurrentMTEnabled -XX:\+CMSClassUnloadingEnabled -XX:\+UseParNewGC -XX:-OmitStackTraceInFastThrow"/)
      }
    end

    context 'should allow to add java_opts with Xms and Xmx' do
      let(:facts) do
        {
        }.merge default_facts
      end
      let(:params) do
        {
          :java_opts => '-Xms3g -Xmx3g -XX:NewRatio=1 -XX:PermSize=128m -XX:MaxPermSize=256m -server -XX:+ResizeTLAB -XX:+UseConcMarkSweepGC -XX:+CMSConcurrentMTEnabled -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:-OmitStackTraceInFastThrow'
        }.merge default_params
      end
      it {
        should contain_file(defaults_path).with_content(/^GRAYLOG_SERVER_JAVA_OPTS="-Xms3g -Xmx3g -XX:NewRatio=1 -XX:PermSize=128m -XX:MaxPermSize=256m -server -XX:\+ResizeTLAB -XX:\+UseConcMarkSweepGC -XX:\+CMSConcurrentMTEnabled -XX:\+CMSClassUnloadingEnabled -XX:\+UseParNewGC -XX:-OmitStackTraceInFastThrow"/)
      }
    end
  end

end

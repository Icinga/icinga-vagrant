require 'spec_helper'

describe('icinga2::feature::api', :type => :class) do
  let(:pre_condition) { [
    "class { 'icinga2': features => [], constants => {'NodeName' => 'host.example.org'} }"
  ] }

  on_supported_os.each do |os, facts|
    let(:facts) do
      facts.merge({
                      :icinga2_puppet_hostcert => '/var/lib/puppet/ssl/certs/host.example.org.pem',
                      :icinga2_puppet_hostprivkey => '/var/lib/puppet/ssl/private_keys/host.example.org.pem',
                      :icinga2_puppet_localcacert => '/var/lib/puppet/ssl/certs/ca.pem',
                  })
    end

    context "#{os} with ensure => present" do
      let(:params) { {:ensure => 'present'} }

      it { is_expected.to contain_icinga2__feature('api').with({'ensure' => 'present'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .that_notifies('Class[icinga2::service]') }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent'} }

      it { is_expected.to contain_icinga2__feature('api').with({'ensure' => 'absent'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' }) }
    end


    context "#{os} with all defaults" do
      it { is_expected.to contain_icinga2__feature('api').with({'ensure' => 'present'}) }

      it { is_expected.to contain_icinga2__object('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .that_notifies('Class[icinga2::service]') }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .with_content(/accept_config = false/)
        .with_content(/accept_commands = false/)
        .without_content(/bind_\w+ =/)
      }

      it { is_expected.to contain_file('/etc/icinga2/pki/host.example.org.key')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/host.example.org.crt')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/ca.crt')  }

      it { is_expected.to contain_icinga2__object__endpoint('NodeName') }

      it { is_expected.to contain_icinga2__object__zone('ZoneName')
        .with({ 'endpoints' => [ 'NodeName' ] }) }
    end


    context "#{os} with pki => puppet" do
      let(:params) { {:pki => 'puppet'} }

      it { is_expected.to contain_file('/etc/icinga2/pki/host.example.org.key')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/host.example.org.crt')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/ca.crt')  }
    end


    context "#{os} with pki => icinga2" do
      let(:params) { {:pki => 'icinga2'} }

      it { is_expected.to contain_exec('icinga2 pki create key') }
      it { is_expected.to contain_exec('icinga2 pki get trusted-cert') }
      it { is_expected.to contain_exec('icinga2 pki request') }
    end

    context "#{os} with pki => ca" do
      let(:params) { {:pki => 'ca'} }

      it { is_expected.to contain_exec('icinga2 pki create certificate signing request') }
      it { is_expected.to contain_exec('icinga2 pki sign certificate') }
    end

    context "#{os} with pki => foo (not a valid value)" do
      let(:params) { {:pki => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
    end


    context "#{os} with pki => none, ssl_key => foo, ssl_cert => bar, ssl_cacert => baz" do
      let(:params) { {:pki => 'none', 'ssl_key' => 'foo', 'ssl_cert' => 'bar', 'ssl_cacert' => 'baz'} }

      it { is_expected.to contain_file('/etc/icinga2/pki/host.example.org.key').with({
        'mode'  => '0600',
      }).with_content(/^foo/) }

      it { is_expected.to contain_file('/etc/icinga2/pki/host.example.org.crt')
        .with_content(/^bar/) }

      it { is_expected.to contain_file('/etc/icinga2/pki/ca.crt')
        .with_content(/^baz/) }
    end


    context "#{os} with ssl_key_path = /foo/bar" do
      let(:params) { {:ssl_key_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .with_content(/key_path = "\/foo\/bar"/) }
    end


    context "#{os} with ssl_key_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:ssl_key_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with ssl_cert_path = /foo/bar" do
      let(:params) { {:ssl_cert_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .with_content(/cert_path = "\/foo\/bar"/) }
    end


    context "#{os} with ssl_cert_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:ssl_cert_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with ssl_cacert_path = /foo/bar" do
      let(:params) { {:ssl_cacert_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .with_content(/ca_path = "\/foo\/bar"/) }
    end


    context "#{os} with ssl_cacert_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:ssl_cacert_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with accept_config => true" do
      let(:params) { {:accept_config => true} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .with_content(/accept_config = true/) }
    end


    context "#{os} with accept_config => false" do
      let(:params) { {:accept_config => false} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .with_content(/accept_config = false/) }
    end


    context "#{os} with accept_config => foo (not a valid boolean)" do
      let(:params) { {:accept_config => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with accept_commands => true" do
      let(:params) { {:accept_commands => true} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .with_content(/accept_commands = true/) }
    end


    context "#{os} with accept_commands => false" do
      let(:params) { {:accept_commands => false} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .with_content(/accept_commands = false/) }
    end


    context "#{os} with accept_commands => foo (not a valid boolean)" do
      let(:params) { {:accept_commands => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with pki => 'icinga2', ca_host => foo" do
      let(:params) { {:pki => 'icinga2', :ca_host => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
                              .with({ 'target' => '/etc/icinga2/features-available/api.conf' }) }
    end


    context "#{os} with pki => 'icinga2', ca_port => 1234" do
      let(:params) { {:pki => 'icinga2',:ca_port => '1234'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
                              .with({ 'target' => '/etc/icinga2/features-available/api.conf' }) }
    end


    context "#{os} with pki => 'icinga2', ca_port => foo (not a valid integer)" do
      let(:params) { {:pki => 'icinga2',:ca_port => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end


    context "#{os} with pki => none, ticket_salt => foo" do
      let(:params) { {:pki => 'none', :ticket_salt => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
        .with_content(/ticket_salt = "foo"/) }
    end


    context "#{os} with endpoints => { foo => {} }" do
      let(:params) { {:endpoints => { 'foo' => {}} }}

      it { is_expected.to contain_icinga2__object__endpoint('foo') }
    end


    context "#{os} with endpoints => foo (not a valid hash)" do
      let(:params) { {:endpoints => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
    end


    context "#{os} with zones => { foo => {endpoints => ['bar']} } }" do
      let(:params) { {:zones => { 'foo' => {'endpoints' => ['bar']}} }}

      it { is_expected.to contain_icinga2__object__zone('foo')
        .with({ 'endpoints' => [ 'bar' ] }) }
    end


    context "#{os} with zones => foo (not a valid hash)" do
      let(:params) { {:zones => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
    end

    context "#{os} with TLS detail settings" do
      let(:params) { { ssl_protocolmin: 'TLSv1.2', ssl_cipher_list: 'HIGH:MEDIUM:!aNULL:!MD5:!RC4' } }

      it 'should set TLS detail setting' do
        is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
          .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
          .with_content(/tls_protocolmin = "TLSv1.2"/)
          .with_content(/cipher_list = "HIGH:MEDIUM:!aNULL:!MD5:!RC4"/)
      end
    end

    context "#{os} with bind settings" do
      let(:params) { { bind_host: '::', bind_port: 1234 } }

      it 'should set bind_* settings' do
        is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
          .with({ 'target' => '/etc/icinga2/features-available/api.conf' })
          .with_content(/bind_host = "::"/)
          .with_content(/bind_port = 1234/)
      end
    end
  end
end


describe('icinga2::feature::api', :type => :class) do
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
    :icinga2_puppet_hostcert => 'C:\Program Files\Puppet Labs\Puppet\var\lib\puppet\ssl\certs\host.example.org.pem',
    :icinga2_puppet_hostprivkey => 'C:\Program Files\Puppet Labs\Puppet\var\lib\puppet\ssl\private_keys\host.example.org.pem',
    :icinga2_puppet_localcacert => 'C:\Program Files\Puppet Labs\Puppet\var\lib\puppet\ssl\certs\ca.pem',
  } }
  let(:pre_condition) { [
    "class { 'icinga2': features => [], constants => {'NodeName' => 'host.example.org'} }"
  ] }


  context 'Windows 2012 R2 with ensure => present' do
    let(:params) { {:ensure => 'present'} }

    it { is_expected.to contain_icinga2__feature('api').with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .that_notifies('Class[icinga2::service]') }
  end


  context 'Windows 2012 R2 with ensure => absent' do
    let(:params) { {:ensure => 'absent'} }

    it { is_expected.to contain_icinga2__feature('api').with({'ensure' => 'absent'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' }) }
  end


  context "Windows 2012 R2 with all defaults" do
    it { is_expected.to contain_icinga2__feature('api').with({'ensure' => 'present'}) }

    it { is_expected.to contain_icinga2__object('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .that_notifies('Class[icinga2::service]') }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .with_content(/accept_config = false/)
      .with_content(/accept_commands = false/) }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/host.example.org.key') }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/host.example.org.crt') }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ca.crt') }

    it { is_expected.to contain_icinga2__object__endpoint('NodeName') }

    it { is_expected.to contain_icinga2__object__zone('ZoneName')
      .with({ 'endpoints' => [ 'NodeName' ] }) }
  end


  context "Windows 2012 R2 with pki => puppet" do
    let(:params) { {:pki => 'puppet'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/host.example.org.key') }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/host.example.org.crt') }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ca.crt') }
  end


  context "Windows 2012 R2 with pki => icinga2" do
    let(:params) { {:pki => 'icinga2'} }

    it { is_expected.to contain_exec('icinga2 pki create key') }
    it { is_expected.to contain_exec('icinga2 pki get trusted-cert') }
    it { is_expected.to contain_exec('icinga2 pki request') }
  end


  context "Windows 2012 R2 with pki => foo (not a valid value)" do
    let(:params) { {:pki => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /foo isn't supported/) }
  end


  context "Windows 2012 R2 with pki => none, ssl_key => foo, ssl_cert => bar, ssl_cacert => baz" do
    let(:params) { {:pki => 'none', 'ssl_key' => 'foo', 'ssl_cert' => 'bar', 'ssl_cacert' => 'baz'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/host.example.org.key')
      .with_content(/^foo/) }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/host.example.org.crt')
      .with_content(/^bar/) }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ca.crt')
      .with_content(/^baz/) }
  end


  context "Windows 2012 R2 with ssl_key_path = /foo/bar" do
    let(:params) { {:ssl_key_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .with_content(/key_path = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with ssl_key_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:ssl_key_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with ssl_cert_path = /foo/bar" do
    let(:params) { {:ssl_cert_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .with_content(/cert_path = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with ssl_cert_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:ssl_cert_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with ssl_cacert_path = /foo/bar" do
    let(:params) { {:ssl_cacert_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .with_content(/ca_path = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with ssl_cacert_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:ssl_cacert_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with accept_config => true" do
    let(:params) { {:accept_config => true} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .with_content(/accept_config = true/) }
  end


  context "Windows 2012 R2 with accept_config => false" do
    let(:params) { {:accept_config => false} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .with_content(/accept_config = false/) }
  end


  context "Windows 2012 R2 with accept_config => foo (not a valid boolean)" do
    let(:params) { {:accept_config => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with accept_commands => true" do
    let(:params) { {:accept_commands => true} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .with_content(/accept_commands = true/) }
  end


  context "Windows 2012 R2 with accept_commands => false" do
    let(:params) { {:accept_commands => false} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .with_content(/accept_commands = false/) }
  end


  context "Windows 2012 R2 with accept_config => foo (not a valid boolean)" do
    let(:params) { {:accept_commands => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with pki => none, ticket_salt => foo" do
    let(:params) { {:pki => 'none', :ticket_salt => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
      .with_content(/ticket_salt = "foo"/) }
  end


  context "Windows 2012 R2 with pki => 'icinga2', ca_host => foo" do
    let(:params) { {:pki => 'icinga2', :ca_host => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' }) }
  end


  context "Windows 2012 R2 with pki => 'icinga2', ca_port => 1234" do
    let(:params) { {:pki => 'icinga2',:ca_port => '1234'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' }) }
  end


  context "Windows 2012 R2 with pki => 'icinga2', ca_port => foo (not a valid integer)" do
    let(:params) { {:pki => 'icinga2',:ca_port => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end


  context "Windows 2012 R2 with endpoints => { foo => {} }" do
    let(:params) { {:endpoints => { 'foo' => {}} }}

    it { is_expected.to contain_icinga2__object__endpoint('foo') }
  end


  context "Windows 2012 R2 with endpoints => foo (not a valid hash)" do
    let(:params) { {:endpoints => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
  end


  context "Windows 2012 R2 with zones => { foo => {endpoints => ['bar']} } }" do
    let(:params) { {:zones => { 'foo' => {'endpoints' => ['bar']}} }}

    it { is_expected.to contain_icinga2__object__zone('foo')
      .with({ 'endpoints' => [ 'bar' ] }) }
  end


  context "Windows 2012 R2 with zones => foo (not a valid hash)" do
    let(:params) { {:zones => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
  end

  context 'Windows 2012 R2 with bind settings' do
    let(:params) { { bind_host: '::', bind_port: 1234 } }

    it 'should set bind_* settings' do
      is_expected.to contain_concat__fragment('icinga2::object::ApiListener::api')
        .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/api.conf' })
        .with_content(/bind_host = "::"/)
        .with_content(/bind_port = 1234/)
    end
  end
end

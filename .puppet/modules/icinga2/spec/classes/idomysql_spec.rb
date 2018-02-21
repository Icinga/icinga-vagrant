require 'spec_helper'

describe('icinga2::feature::idomysql', :type => :class) do
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

      it { is_expected.to contain_icinga2__feature('ido-mysql').with({'ensure' => 'present'}) }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent'} }

      it { is_expected.to contain_icinga2__feature('ido-mysql').with({'ensure' => 'absent'}) }
    end

    context "#{os} with all defaults" do
      it { is_expected.to contain_icinga2__feature('ido-mysql').with({'ensure' => 'present'}) }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
        .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
        .with_content(/host = "127.0.0.1"/)
        .with_content(/port = 3306/)
        .with_content(/user = "icinga"/)
        .with_content(/password = "icinga"/)
        .with_content(/enable_ssl = false/)
        .with_content(/table_prefix = "icinga_"/)
        .with_content(/instance_name = "default"/)
        .with_content(/enable_ha = true/)
        .with_content(/failover_timeout = 60s/) }
    end


    context "#{os} with host => foo.example.com" do
      let(:params) { {:host => 'foo.example.com'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/host = "foo.example.com"/) }
    end


    context "#{os} with port => 4247" do
      let(:params) { {:port => '4247'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/port = 4247/) }
    end


    context "#{os} with port => foo (not a valid integer)" do
      let(:params) { {:port => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end


    context "#{os} with socket_path => /foo/bar" do
      let(:params) { {:socket_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                           .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                           .with_content(/socket_path = "\/foo\/bar"/) }
    end


    context "#{os} with socket_path => foo/bar (not an absolute path)" do
      let(:params) { {:socket_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with user => foo" do
      let(:params) { {:user => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/user = "foo"/) }
    end


    context "#{os} with database => foo" do
      let(:params) { {:database => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/database = "foo"/) }
    end


    context "#{os} with enable_ssl => false" do
      let(:params) { {:enable_ssl => false} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/enable_ssl = false/)
                              .without_content(/ssl_ca =/)
                              .without_content(/ssl_cert =/)
                              .without_content(/ssl_key =/) }
    end


    context "#{os} with enable_ssl => true, pki => puppet" do
      let(:params) { {:enable_ssl => true, :pki => 'puppet'} }

      it { is_expected.to contain_file('/etc/icinga2/pki/ido-mysql/host.example.org.key')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/ido-mysql/host.example.org.crt')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/ido-mysql/ca.crt')  }
    end


    context "#{os} with pki => foo (not a valid value)" do
      let(:params) { {:pki => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /Valid values are 'puppet' and 'none'/) }
    end


    context "#{os} with enable_ssl = true, pki => none, ssl_key => foo, ssl_cert => bar, ssl_cacert => baz" do
      let(:params) { {:enable_ssl => true, :pki => 'none', 'ssl_key' => 'foo', 'ssl_cert' => 'bar', 'ssl_cacert' => 'baz'} }

      it { is_expected.to contain_file('/etc/icinga2/pki/ido-mysql/host.example.org.key').with({
                                                                                                  'mode'  => '0600',
                                                                                              }).with_content(/^foo/) }

      it { is_expected.to contain_file('/etc/icinga2/pki/ido-mysql/host.example.org.crt')
                              .with_content(/^bar/) }

      it { is_expected.to contain_file('/etc/icinga2/pki/ido-mysql/ca.crt')
                              .with_content(/^baz/) }
    end


    context "#{os} with enable_ssl = true, ssl_key_path = /foo/bar" do
      let(:params) { {:enable_ssl => true, :ssl_key_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/ssl_key = "\/foo\/bar"/) }
    end


    context "#{os} with enable_ssl = true, ssl_key_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:enable_ssl => true, :ssl_key_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with enable_ssl = true, ssl_cert_path = /foo/bar" do
      let(:params) { {:enable_ssl => true, :ssl_cert_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/ssl_cert = "\/foo\/bar"/) }
    end


    context "#{os} with enable_ssl = true, ssl_cert_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:enable_ssl => true, :ssl_cert_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with enable_ssl = true, ssl_cacert_path = /foo/bar" do
      let(:params) { {:enable_ssl => true, :ssl_cacert_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/ssl_ca = "\/foo\/bar"/) }
    end


    context "#{os} with enable_ssl = true, ssl_cacert_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:enable_ssl => true, :ssl_cacert_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with enabl_ssl = true, pki = none, ssl_cipher = foo" do
      let(:params) { {:enable_ssl => true,:pki => 'none', :ssl_cipher => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/enable_ssl = true/)
                              .with_content(/ssl_cipher = "foo"/) }
    end


    context "#{os} with enabl_ssl = true, pki = none, ssl_capath = /foo" do
      let(:params) { {:enable_ssl => true,:pki => 'none', :ssl_capath => '/foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/enable_ssl = true/)
                              .with_content(/ssl_capath = "\/foo"/) }
    end


    context "#{os} with enabl_ssl = true, pki = none, ssl_capath = foo" do
      let(:params) { {:enable_ssl => true,:pki => 'none', :ssl_capath => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not an absolute path/) }
    end


    context "#{os} with table_prefix => foo" do
      let(:params) { {:table_prefix => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/table_prefix = "foo"/) }
    end


    context "#{os} with instance_name => foo" do
      let(:params) { {:instance_name => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/instance_name = "foo"/) }
    end


    context "#{os} with enable_ha => true" do
      let(:params) { {:enable_ha => true} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/enable_ha = true/) }
    end


    context "#{os} with enable_ha => false" do
      let(:params) { {:enable_ha => false} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/enable_ha = false/) }
    end


    context "#{os} with enable_ha => foo (not a valid boolean)" do
      let(:params) { {:enable_ha => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with failover_timeout => 50s" do
      let(:params) { {:failover_timeout => '50s'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/failover_timeout = 50s/) }
    end


    context "#{os} with failover_timeout => foo (not a valid value)" do
      let(:params) { {:failover_timeout => "foo"} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end


    context "#{os} with cleanup => { foo => 'bar', bar => 'foo' }" do
      let(:params) { {:cleanup => { 'foo' => "bar", 'bar' => "foo" } } }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/cleanup = {\n\s+foo = "bar"\n\s+bar = "foo"\n\s+}/) }
    end


    context "#{os} with cleanup => 'foo' (not a valid hash)" do
      let(:params) { {:cleanup => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
    end


    context "#{os} with categories => ['foo', 'bar']" do
      let(:params) { {:categories => ['foo', 'bar'] } }

      it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                              .with({ 'target' => '/etc/icinga2/features-available/ido-mysql.conf' })
                              .with_content(/categories = \[ "foo", "bar", \]/) }
    end


    context "#{os} with categories => 'foo' (not a valid array)" do
      let(:params) { {:categories => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
    end


    context "#{os} with import_schema => true" do
      let(:params) { {:import_schema => true} }

      it { is_expected.to contain_exec('idomysql-import-schema') }
    end


    context "#{os} with import_schema => false" do
      let(:params) { {:import_schema => false} }

      it { should_not contain_exec('idomysql-import-schema') }
    end


    context "#{os} with import_schema => foo (not a valid boolean)" do
      let(:params) { {:import_schema => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with icinga2::manage_package => true" do
      let(:pre_condition) { [
          "class { 'icinga2': features => [], manage_package => true }"
      ] }

      it { is_expected.to contain_package('icinga2').with({ 'ensure' => 'installed' }) }
    end

    context "#{os} with icinga2::manage_package => false" do
      let(:pre_condition) { [
          "class { 'icinga2': features => [], manage_package => false }"
      ] }

      it { should_not contain_package('icinga2').with({ 'ensure' => 'installed' }) }
    end
  end
end

describe('icinga2::feature::idomysql', :type => :class) do
  let(:pre_condition) { [
      "class { 'icinga2': features => [], constants => {'NodeName' => 'host.example.org'} }"
  ] }

  let(:facts) { {
      :kernel => 'Windows',
      :architecture => 'x86_64',
      :osfamily => 'Windows',
      :operatingsystem => 'Windows',
      :operatingsystemmajrelease => '2012 R2',
      :fqdn => 'foo.bar.com',
      :path => 'C:/Program Files/MySQL/bin',
      :icinga2_puppet_hostcert => 'C:\Program Files\Puppet Labs\Puppet\var\lib\puppet\ssl\certs\host.example.org.pem',
      :icinga2_puppet_hostprivkey => 'C:\Program Files\Puppet Labs\Puppet\var\lib\puppet\ssl\private_keys\host.example.org.pem',
      :icinga2_puppet_localcacert => 'C:\Program Files\Puppet Labs\Puppet\var\lib\puppet\ssl\certs\ca.pem',
  } }


  context "Windows 2012 R2 with ensure => present" do
    let(:params) { {:ensure => 'present'} }

    it { is_expected.to contain_icinga2__feature('ido-mysql').with({'ensure' => 'present'}) }
  end


  context "Windows 2012 R2 with ensure => absent" do
    let(:params) { {:ensure => 'absent'} }

    it { is_expected.to contain_icinga2__feature('ido-mysql').with({'ensure' => 'absent'}) }
  end

  context "Windows 2012 R2 with all defaults" do
    it { is_expected.to contain_icinga2__feature('ido-mysql').with({'ensure' => 'present'}) }


    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/host = "127.0.0.1"/)
                            .with_content(/port = 3306/)
                            .with_content(/user = "icinga"/)
                            .with_content(/password = "icinga"/)
                            .with_content(/enable_ssl = false/)
                            .with_content(/table_prefix = "icinga_"/)
                            .with_content(/instance_name = "default"/)
                            .with_content(/enable_ha = true/)
                            .with_content(/failover_timeout = 60s/) }
  end


  context "Windows 2012 R2 with host => foo.example.com" do
    let(:params) { {:host => 'foo.example.com'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/host = "foo.example.com"/) }
  end


  context "Windows 2012 R2 with port => 4247" do
    let(:params) { {:port => '4247'} }


    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/port = 4247/) }
  end


  context "Windows 2012 R2 with port => foo (not a valid integer)" do
    let(:params) { {:port => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end


  context "Windows 2012 R2 with socket_path => /foo/bar" do
    let(:params) { {:socket_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/socket_path = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with socket_path => foo/bar (not an absolute path)" do
    let(:params) { {:socket_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with user => foo" do
    let(:params) { {:user => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/user = "foo"/) }
  end


  context "Windows 2012 R2 with database => foo" do
    let(:params) { {:database => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/database = "foo"/) }
  end


  context "Windows 2012 R2 with enable_ssl => false" do
    let(:params) { {:enable_ssl => false} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/enable_ssl = false/)
                            .without_content(/ssl_ca =/)
                            .without_content(/ssl_cert =/)
                            .without_content(/ssl_key =/) }
  end


  context "Windows 2012 R2 with enable_ssl => true, pki => puppet" do
    let(:params) { {:enable_ssl => true, :pki => 'puppet'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ido-mysql/host.example.org.key')  }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ido-mysql/host.example.org.crt')  }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ido-mysql/ca.crt')  }
  end


  context "Windows 2012 R2 with pki => foo (not a valid value)" do
    let(:params) { {:pki => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /Valid values are 'puppet' and 'none'/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, pki => none, ssl_key => foo, ssl_cert => bar, ssl_cacert => baz" do
    let(:params) { {:enable_ssl => true, :pki => 'none', 'ssl_key' => 'foo', 'ssl_cert' => 'bar', 'ssl_cacert' => 'baz'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ido-mysql/host.example.org.key').with_content(/^foo/) }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ido-mysql/host.example.org.crt')
                            .with_content(/^bar/) }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ido-mysql/ca.crt')
                            .with_content(/^baz/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_key_path = /foo/bar" do
    let(:params) { {:enable_ssl => true, :ssl_key_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/ssl_key = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_key_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:enable_ssl => true, :ssl_key_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_cert_path = /foo/bar" do
    let(:params) { {:enable_ssl => true, :ssl_cert_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/ssl_cert = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_cert_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:enable_ssl => true, :ssl_cert_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_cacert_path = /foo/bar" do
    let(:params) { {:enable_ssl => true, :ssl_cacert_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/ssl_ca = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_cacert_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:enable_ssl => true, :ssl_cacert_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with enabl_ssl = true, pki = none, ssl_cipher = foo" do
    let(:params) { {:enable_ssl => true,:pki => 'none', :ssl_cipher => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/enable_ssl = true/)
                            .with_content(/ssl_cipher = "foo"/) }
  end


  context "Windows 2012 R2 with enabl_ssl = true, pki = none, ssl_capath = /foo" do
    let(:params) { {:enable_ssl => true,:pki => 'none', :ssl_capath => '/foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/enable_ssl = true/)
                            .with_content(/ssl_capath = "\/foo"/) }
  end


  context "Windows 2012 R2 with enabl_ssl = true, pki = none, ssl_capath = foo" do
    let(:params) { {:enable_ssl => true,:pki => 'none', :ssl_capath => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not an absolute path/) }
  end


  context "Windows 2012 R2 with table_prefix => foo" do
    let(:params) { {:table_prefix => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/table_prefix = "foo"/) }
  end


  context "Windows 2012 R2 with instance_name => foo" do
    let(:params) { {:instance_name => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/instance_name = "foo"/) }
  end


  context "Windows 2012 R2 with enable_ha => true" do
    let(:params) { {:enable_ha => true} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/enable_ha = true/) }
  end


  context "Windows 2012 R2 with enable_ha => false" do
    let(:params) { {:enable_ha => false} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/enable_ha = false/) }
  end


  context "Windows 2012 R2 with enable_ha => foo (not a valid boolean)" do
    let(:params) { {:enable_ha => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with failover_timeout => 50s" do
    let(:params) { {:failover_timeout => '50s'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/failover_timeout = 50s/) }
  end


  context "Windows 2012 R2 with failover_timeout => foo (not a valid value)" do
    let(:params) { {:failover_timeout => "foo"} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end


  context "Windows 2012 R2 with cleanup => { foo => 'bar', bar => 'foo' }" do
    let(:params) { {:cleanup => { 'foo' => "bar", 'bar' => "foo" } } }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/cleanup = {\r\n\s+foo = "bar"\r\n\s+bar = "foo"\r\n\s+}/) }
  end


  context "Windows 2012 R2 with cleanup => 'foo' (not a valid hash)" do
    let(:params) { {:cleanup => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
  end


  context "Windows 2012 R2 with categories => ['foo', 'bar']" do
    let(:params) { {:categories => ['foo', 'bar'] } }

    it { is_expected.to contain_concat__fragment('icinga2::object::IdoMysqlConnection::ido-mysql')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/ido-mysql.conf' })
                            .with_content(/categories = \[ "foo", "bar", \]/) }
  end


  context "Windows 2012 R2 with categories => 'foo' (not a valid array)" do
    let(:params) { {:categories => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not an Array/) }
  end


  context "Windows 2012 R2 with import_schema => true" do
    let(:params) { {:import_schema => true} }

    it { is_expected.to contain_exec('idomysql-import-schema') }
  end


  context "Windows 2012 R2 with import_schema => false" do
    let(:params) { {:import_schema => false} }

    it { should_not contain_exec('idomysql-import-schema') }
  end


  context "Windows 2012 R2 with import_schema => foo (not a valid boolean)" do
    let(:params) { {:import_schema => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end

  context "Windows 2012 R2 with icinga2::manage_package => true" do
    let(:pre_condition) { [
        "class { 'icinga2': features => [], manage_package => true }"
    ] }

    it { is_expected.to contain_package('icinga2').with({ 'ensure' => 'installed' }) }
  end

  context "Windows 2012 R2 with icinga2::manage_package => false" do
    let(:pre_condition) { [
        "class { 'icinga2': features => [], manage_package => false }"
    ] }

    it { should_not contain_package('icinga2').with({ 'ensure' => 'installed' }) }
  end
end

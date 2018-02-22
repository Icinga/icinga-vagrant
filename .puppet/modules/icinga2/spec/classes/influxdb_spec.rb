require 'spec_helper'

describe('icinga2::feature::influxdb', :type => :class) do
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

      it { is_expected.to contain_icinga2__feature('influxdb').with({'ensure' => 'present'}) }
    end


    context "#{os} with ensure => absent" do
      let(:params) { {:ensure => 'absent'} }

      it { is_expected.to contain_icinga2__feature('influxdb').with({'ensure' => 'absent'}) }
    end


    context "#{os} with all defaults" do
      it { is_expected.to contain_icinga2__feature('influxdb').with({'ensure' => 'present'}) }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
        .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
        .with_content(/host = "127.0.0.1"/)
        .with_content(/port = 8086/)
        .with_content(/database = "icinga2"/)
        .without_content(/username = /)
        .without_content(/password = /)
        .with_content(/ssl_enable = false/)
        .with_content(/enable_send_thresholds = false/)
        .with_content(/enable_send_metadata = false/)
        .with_content(/flush_interval = 10s/)
        .with_content(/flush_threshold = 1024/)
        .with_content(/host_template = {\n\s+measurement = "\$host.check_command\$"\n\s+tags = \{\n\s+hostname = "\$host.name\$"\n\s+\}\n\s+\}/)
        .with_content(/service_template = {\n\s+measurement = "\$service.check_command\$"\n\s+tags = \{\n\s+hostname = "\$host.name\$"\n\s+service = "\$service.name\$"\n\s+\}\n\s+/)}
    end


    context "#{os} with host => foo.example.com" do
      let(:params) { {:host => 'foo.example.com'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/host = "foo.example.com"/) }
    end


    context "#{os} with port => 4247" do
      let(:params) { {:port => 4247} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/port = 4247/) }
    end


    context "#{os} with port => foo (not a valid integer)" do
      let(:params) { {:port => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end


    context "#{os} with database => foo" do
      let(:params) { {:database => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/database = "foo"/) }
    end


    context "#{os} with username => foo" do
      let(:params) { {:username => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/username = "foo"/) }
    end


    context "#{os} with password => foo" do
      let(:params) { {:password => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/password = "foo"/) }
    end


    context "#{os} with enable_ssl => false" do
      let(:params) { {:enable_ssl => false} }


      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/ssl_enable = false/)
                              .without_content(/ssl_ca_cert =/)
                              .without_content(/ssl_cert =/)
                              .without_content(/ssl_key/) }
    end


    context "#{os} with enable_ssl => true, pki => puppet" do
      let(:params) { {:enable_ssl => true, :pki => 'puppet'} }

      it { is_expected.to contain_file('/etc/icinga2/pki/influxdb/host.example.org.key')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/influxdb/host.example.org.crt')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/influxdb/ca.crt')  }
    end


    context "#{os} with pki => foo (not a valid value)" do
      let(:params) { {:pki => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /Valid values are 'puppet' and 'none'/) }
    end


    context "#{os} with enable_ssl = true, pki => none, ssl_key => foo, ssl_cert => bar, ssl_cacert => baz" do
      let(:params) { {:enable_ssl => true, :pki => 'none', 'ssl_key' => 'foo', 'ssl_cert' => 'bar', 'ssl_cacert' => 'baz'} }

      it { is_expected.to contain_file('/etc/icinga2/pki/influxdb/host.example.org.key').with({
                                                                                         'mode'  => '0600',
                                                                                     }).with_content(/^foo/) }

      it { is_expected.to contain_file('/etc/icinga2/pki/influxdb/host.example.org.crt')
                              .with_content(/^bar/) }

      it { is_expected.to contain_file('/etc/icinga2/pki/influxdb/ca.crt')
                              .with_content(/^baz/) }
    end


    context "#{os} with enable_ssl = true, ssl_key_path = /foo/bar" do
      let(:params) { {:enable_ssl => true, :ssl_key_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/ssl_key = "\/foo\/bar"/) }
    end


    context "#{os} with enable_ssl = true, ssl_key_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:enable_ssl => true, :ssl_key_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with enable_ssl = true, ssl_cert_path = /foo/bar" do
      let(:params) { {:enable_ssl => true, :ssl_cert_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/ssl_cert = "\/foo\/bar"/) }
    end


    context "#{os} with enable_ssl = true, ssl_cert_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:enable_ssl => true, :ssl_cert_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with enable_ssl = true, ssl_cacert_path = /foo/bar" do
      let(:params) { {:enable_ssl => true, :ssl_cacert_path => '/foo/bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/ssl_ca_cert = "\/foo\/bar"/) }
    end


    context "#{os} with enable_ssl = true, ssl_cacert_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:enable_ssl => true, :ssl_cacert_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with host_measurement => foo" do
      let(:params) { {:host_measurement => 'foo'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/host_template = {\n\s+measurement = "foo"/) }
    end


    context "#{os} with host_tags => { foo => 'bar', bar => 'foo' }" do
      let(:params) { {:host_tags => { 'foo' => "bar", 'bar' => "foo" } } }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/host_template = {\n\s+measurement = ".*"\n\s+tags = \{\n\s+foo = "bar"\n\s+bar = "foo"\n\s+}\n\s+}/) }
    end


    context "#{os} with host_tags => 'foo' (not a valid hash)" do
      let(:params) { {:host_tags => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
    end


    context "#{os} with service_measurement => bar" do
      let(:params) { {:service_measurement => 'bar'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/service_template = {\n\s+measurement = "bar"/) }
    end


    context "#{os} with service_tags => { foo => 'bar', bar => 'foo' }" do
      let(:params) { {:service_tags => { 'foo' => "bar", 'bar' => "foo" } } }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/service_template = {\n\s+measurement = ".*"\n\s+tags = \{\n\s+foo = "bar"\n\s+bar = "foo"\n\s+}\n\s+}/) }
    end


    context "#{os} with service_tags => 'foo' (not a valid hash)" do
      let(:params) { {:service_tags => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
    end


    context "#{os} with enable_send_thresholds => true" do
      let(:params) { {:enable_send_thresholds => true} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/enable_send_thresholds = true/) }
    end


    context "#{os} with enable_send_thresholds => false" do
      let(:params) { {:enable_send_thresholds => false} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/enable_send_thresholds = false/) }
    end


    context "#{os} with enable_send_thresholds => foo (not a valid boolean)" do
      let(:params) { {:enable_send_thresholds => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end


    context "#{os} with enable_send_metadata => true" do
      let(:params) { {:enable_send_metadata => true} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/enable_send_metadata = true/) }
    end


    context "#{os} with enable_send_metadata => false" do
      let(:params) { {:enable_send_metadata => false} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/enable_send_metadata = false/) }
    end


    context "#{os} with enable_send_metadata => foo (not a valid boolean)" do
      let(:params) { {:enable_send_metadata => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
    end

    context "#{os} with flush_interval => 50s" do
      let(:params) { {:flush_interval => '50s'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/flush_interval = 50s/) }
    end


    context "#{os} with flush_interval => foo (not a valid value)" do
      let(:params) { {:flush_interval => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
    end


    context "#{os} with flush_threshold => 2048" do
      let(:params) { {:flush_threshold => '2048'} }

      it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                              .with({ 'target' => '/etc/icinga2/features-available/influxdb.conf' })
                              .with_content(/flush_threshold = 2048/) }
    end


    context "#{os} with flush_threshold => foo (not a valid integer)" do
      let(:params) { {:flush_threshold => 'foo'} }

      it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
    end
  end
end



describe('icinga2::feature::influxdb', :type => :class) do
  let(:pre_condition) { [
      "class { 'icinga2': features => [], constants => {'NodeName' => 'host.example.org'} }"
  ] }

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
      C:\ProgramData\chocolatey\bin;
      C:\Users\vagrant\AppData\Roaming\Boxstarter',
    :icinga2_puppet_hostcert => 'C:\Program Files\Puppet Labs\Puppet\var\lib\puppet\ssl\certs\host.example.org.pem',
    :icinga2_puppet_hostprivkey => 'C:\Program Files\Puppet Labs\Puppet\var\lib\puppet\ssl\private_keys\host.example.org.pem',
    :icinga2_puppet_localcacert => 'C:\Program Files\Puppet Labs\Puppet\var\lib\puppet\ssl\certs\ca.pem',
  } }

  context "Windows 2012 R2 with ensure => present" do
    let(:params) { {:ensure => 'present'} }

    it { is_expected.to contain_icinga2__feature('influxdb').with({'ensure' => 'present'}) }
  end


  context "Windows 2012 R2 with ensure => absent" do
    let(:params) { {:ensure => 'absent'} }

    it { is_expected.to contain_icinga2__feature('influxdb').with({'ensure' => 'absent'}) }
  end


  context "Windows 2012 R2 with all defaults" do
    it { is_expected.to contain_icinga2__feature('influxdb').with({'ensure' => 'present'}) }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
      .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
      .with_content(/host = "127.0.0.1"/)
      .with_content(/port = 8086/)
      .with_content(/database = "icinga2"/)
      .without_content(/username = /)
      .without_content(/password = /)
      .with_content(/ssl_enable = false/)
      .with_content(/enable_send_thresholds = false/)
      .with_content(/enable_send_metadata = false/)
      .with_content(/flush_interval = 10s/)
      .with_content(/flush_threshold = 1024/)
      .with_content(/host_template = {\r\n\s+measurement = "\$host.check_command\$"\r\n\s+tags = \{\r\n\s+hostname = "\$host.name\$"\r\n\s+\}\r\n\s+\}/)
      .with_content(/service_template = {\r\n\s+measurement = "\$service.check_command\$"\r\n\s+tags = \{\r\n\s+hostname = "\$host.name\$"\r\n\s+service = "\$service.name\$"\r\n\s+\}\r\n\s+/)}
  end


  context "Windows 2012 R2 with host => foo.example.com" do
    let(:params) { {:host => 'foo.example.com'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/host = "foo.example.com"/) }
  end


  context "Windows 2012 R2 with port => 4247" do
    let(:params) { {:port => 4247} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/port = 4247/) }
  end


  context "Windows 2012 R2 with port => foo (not a valid integer)" do
    let(:params) { {:port => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end


  context "Windows 2012 R2 with database => foo" do
    let(:params) { {:database => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/database = "foo"/) }
  end


  context "Windows 2012 R2 with username => foo" do
    let(:params) { {:username => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/username = "foo"/) }
  end


  context "Windows 2012 R2 with password => foo" do
    let(:params) { {:password => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/password = "foo"/) }
  end


  context "Windows 2012 R2 with enable_ssl => false" do
    let(:params) { {:enable_ssl => false} }


    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/ssl_enable = false/)
                            .without_content(/ssl_ca_cert =/)
                            .without_content(/ssl_cert =/)
                            .without_content(/ssl_key/) }
  end


  context "Windows 2012 R2 with enable_ssl => true, pki => puppet" do
    let(:params) { {:enable_ssl => true, :pki => 'puppet'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/influxdb/host.example.org.key')  }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/influxdb/host.example.org.crt')  }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/influxdb/ca.crt')  }
  end


  context "Windows 2012 R2 with pki => foo (not a valid value)" do
    let(:params) { {:pki => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /Valid values are 'puppet' and 'none'/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, pki => none, ssl_key => foo, ssl_cert => bar, ssl_cacert => baz" do
    let(:params) { {:enable_ssl => true, :pki => 'none', 'ssl_key' => 'foo', 'ssl_cert' => 'bar', 'ssl_cacert' => 'baz'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/influxdb/host.example.org.key').with({
                                                                                            }).with_content(/^foo/) }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/influxdb/host.example.org.crt')
                            .with_content(/^bar/) }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/influxdb/ca.crt')
                            .with_content(/^baz/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_key_path = /foo/bar" do
    let(:params) { {:enable_ssl => true, :ssl_key_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/ssl_key = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_key_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:enable_ssl => true, :ssl_key_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_cert_path = /foo/bar" do
    let(:params) { {:enable_ssl => true, :ssl_cert_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/ssl_cert = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_cert_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:enable_ssl => true, :ssl_cert_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_cacert_path = /foo/bar" do
    let(:params) { {:enable_ssl => true, :ssl_cacert_path => '/foo/bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/ssl_ca_cert = "\/foo\/bar"/) }
  end


  context "Windows 2012 R2 with enable_ssl = true, ssl_cacert_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:enable_ssl => true, :ssl_cacert_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with host_measurement => foo" do
    let(:params) { {:host_measurement => 'foo'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/host_template = {\r\n\s+measurement = "foo"/) }
  end


  context "Windows 2012 R2 with host_tags => { foo => 'bar', bar => 'foo' }" do
    let(:params) { {:host_tags => { 'foo' => "bar", 'bar' => "foo" } } }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/host_template = {\r\n\s+measurement = ".*"\r\n\s+tags = \{\r\n\s+foo = "bar"\r\n\s+bar = "foo"\r\n\s+}\r\n\s+}/) }
  end


  context "Windows 2012 R2 with host_tags => 'foo' (not a valid hash)" do
    let(:params) { {:host_tags => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
  end


  context "Windows 2012 R2 with service_measurement => bar" do
    let(:params) { {:service_measurement => 'bar'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/service_template = {\r\n\s+measurement = "bar"/) }
  end


  context "Windows 2012 R2 with service_tags => { foo => 'bar', bar => 'foo' }" do
    let(:params) { {:service_tags => { 'foo' => "bar", 'bar' => "foo" } } }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/service_template = {\r\n\s+measurement = ".*"\r\n\s+tags = \{\r\n\s+foo = "bar"\r\n\s+bar = "foo"\r\n\s+}\r\n\s+}/) }
  end


  context "Windows 2012 R2 with service_tags => 'foo' (not a valid hash)" do
    let(:params) { {:service_tags => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a Hash/) }
  end


  context "Windows 2012 R2 with enable_send_thresholds => true" do
    let(:params) { {:enable_send_thresholds => true} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/enable_send_thresholds = true/) }
  end


  context "Windows 2012 R2 with enable_send_thresholds => false" do
    let(:params) { {:enable_send_thresholds => false} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/enable_send_thresholds = false/) }
  end


  context "Windows 2012 R2 with enable_send_thresholds => foo (not a valid boolean)" do
    let(:params) { {:enable_send_thresholds => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end


  context "Windows 2012 R2 with enable_send_metadata => true" do
    let(:params) { {:enable_send_metadata => true} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/enable_send_metadata = true/) }
  end


  context "Windows 2012 R2 with enable_send_metadata => false" do
    let(:params) { {:enable_send_metadata => false} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/enable_send_metadata = false/) }
  end


  context "Windows 2012 R2 with enable_send_metadata => foo (not a valid boolean)" do
    let(:params) { {:enable_send_metadata => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" is not a boolean/) }
  end

  context "Windows 2012 R2 with flush_interval => 50s" do
    let(:params) { {:flush_interval => '50s'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/flush_interval = 50s/) }
  end


  context "Windows 2012 R2 with flush_interval => foo (not a valid value)" do
    let(:params) { {:flush_interval => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo" does not match/) }
  end


  context "Windows 2012 R2 with flush_threshold => 2048" do
    let(:params) { {:flush_threshold => '2048'} }

    it { is_expected.to contain_concat__fragment('icinga2::object::InfluxdbWriter::influxdb')
                            .with({ 'target' => 'C:/ProgramData/icinga2/etc/icinga2/features-available/influxdb.conf' })
                            .with_content(/flush_threshold = 2048/) }
  end


  context "Windows 2012 R2 with flush_threshold => foo (not a valid integer)" do
    let(:params) { {:flush_threshold => 'foo'} }

    it { is_expected.to raise_error(Puppet::Error, /first argument to be an Integer/) }
  end

end

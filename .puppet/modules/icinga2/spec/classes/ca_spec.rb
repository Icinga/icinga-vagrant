require 'spec_helper'

describe('icinga2::pki::ca', :type => :class) do
  let(:pre_condition) { [
      "class { 'icinga2': features => [], constants => {'NodeName' => 'host.example.org'} }"
  ] }

  before(:all) do
    @ca_cert = "/var/lib/icinga2/ca/ca.crt"
    @ca_key = "/var/lib/icinga2/ca/ca.key"
  end

  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end

    context "#{os} with defaults (no params)" do
      it { is_expected.to contain_exec('create-icinga2-ca') }

      it { is_expected.to contain_file('/etc/icinga2/pki/host.example.org.key')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/host.example.org.crt')  }
      it { is_expected.to contain_file('/etc/icinga2/pki/ca.crt')  }
    end


    context "#{os} with ca_cert => 'foo', ca_key => 'bar'" do
      let(:params) {{:ca_cert => 'foo', :ca_key => 'bar'}}

      it { is_expected.to contain_file(@ca_cert).with_content(/foo/) }
      it { is_expected.to contain_file(@ca_key).with_content(/bar/) }
    end

    context "#{os} with ssl_key_path = /foo/bar" do
      let(:params) { {:ssl_key_path => '/foo/bar'} }

      it { is_expected.to contain_file('/foo/bar')  }
    end


    context "#{os} with ssl_key_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:ssl_key_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with ssl_cert_path = /foo/bar" do
      let(:params) { {:ssl_cert_path => '/foo/bar'} }

      it { is_expected.to contain_file('/foo/bar')  }
    end


    context "#{os} with ssl_cert_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:ssl_cert_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with ssl_csr_path = /foo/bar" do
      let(:params) { {:ssl_csr_path => '/foo/bar'} }

      it { is_expected.to contain_file('/foo/bar')  }
    end


    context "#{os} with ssl_csr_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:ssl_csr_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end


    context "#{os} with ssl_cacert_path = /foo/bar" do
      let(:params) { {:ssl_cacert_path => '/foo/bar'} }

      it { is_expected.to contain_file('/foo/bar')  }
    end


    context "#{os} with ssl_cacert_path = foo/bar (not a valid absolute path)" do
      let(:params) { {:ssl_cacert_path => 'foo/bar'} }

      it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
    end
  end
end

describe('icinga2::pki::ca', :type => :class) do
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
  let(:pre_condition) { [
      "class { 'icinga2': features => [], constants => {'NodeName' => 'host.example.org'} }"
  ] }

  before(:all) do
    @ca_cert = "C:/ProgramData/icinga2/var/lib/icinga2/ca/ca.crt"
    @ca_key = "C:/ProgramData/icinga2/var/lib/icinga2/ca/ca.key"
  end


  context "Windows 2012 R2 with defaults (no params)" do
    it { is_expected.to contain_exec('create-icinga2-ca') }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/host.example.org.key')  }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/host.example.org.crt')  }
    it { is_expected.to contain_file('C:/ProgramData/icinga2/etc/icinga2/pki/ca.crt')  }
  end


  context "Windows 2012 R2 with ca_cert => 'foo', ca_key => 'bar'" do
    let(:params) {{:ca_cert => 'foo', :ca_key => 'bar'}}

    it { is_expected.to contain_file(@ca_cert).with_content(/foo/) }
    it { is_expected.to contain_file(@ca_key).with_content(/bar/) }
  end

  context "Windows 2012 R2 with ssl_key_path = /foo/bar" do
    let(:params) { {:ssl_key_path => 'C:/ProgramData/icinga2/foo/bar'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/foo/bar')  }
  end


  context "Windows 2012 R2 with ssl_key_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:ssl_key_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with ssl_cert_path = C:/ProgramData/icinga2/foo/bar" do
    let(:params) { {:ssl_cert_path => 'C:/ProgramData/icinga2/foo/bar'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/foo/bar')  }
  end


  context "Windows 2012 R2 with ssl_cert_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:ssl_cert_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with ssl_csr_path = C:/ProgramData/icinga2/foo/bar" do
    let(:params) { {:ssl_csr_path => 'C:/ProgramData/icinga2/foo/bar'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/foo/bar')  }
  end


  context "Windows 2012 R2 with ssl_csr_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:ssl_csr_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


  context "Windows 2012 R2 with ssl_cacert_path = C:/ProgramData/icinga2/foo/bar" do
    let(:params) { {:ssl_cacert_path => 'C:/ProgramData/icinga2/foo/bar'} }

    it { is_expected.to contain_file('C:/ProgramData/icinga2/foo/bar')  }
  end


  context "Windows 2012 R2 with ssl_cacert_path = foo/bar (not a valid absolute path)" do
    let(:params) { {:ssl_cacert_path => 'foo/bar'} }

    it { is_expected.to raise_error(Puppet::Error, /"foo\/bar" is not an absolute path/) }
  end


end




require 'spec_helper'

describe Facter::Util::Fact do
  on_supported_os.each do |os, facts|
    let :facts do
      facts
    end

    context "#{os} icinga2_puppet_localcacert fact" do
      it { expect(Facter.fact(:icinga2_puppet_localcacert).value).to match(/\/ssl\/certs\/.*.pem/) }
    end
  end
end

describe('icinga2::feature::gelf', :type => :class) do
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

  context "Windows 2012 R2 icinga2_puppet_localcacert fact" do
    it { expect(Facter.fact(:icinga2_puppet_localcacert).value).to match(/\/ssl\/certs\/.*.pem/) }
  end

end

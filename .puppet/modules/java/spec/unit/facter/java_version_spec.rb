require 'spec_helper'

openjdk_7_output = "Picked up JAVA_TOOL_OPTIONS: -Djava.net.preferIPv4Stack=true\n"\
                   "openjdk version \"1.7.0_71\"\n"\
                   "OpenJDK Runtime Environment (build 1.7.0_71-b14)\n"\
                   "OpenJDK 64-Bit Server VM (build 24.71-b01, mixed mode)\n"

jdk_7_hotspot_output = "Picked up JAVA_TOOL_OPTIONS: -Djava.net.preferIPv4Stack=true\n"\
                       "java version \"1.7.0_71\"\n"\
                       "Java(TM) SE Runtime Environment (build 1.7.0_71-b14)\n"\
                       "Java HotSpot(TM) 64-Bit Server VM (build 24.71-b01, mixed mode)\n"

describe 'java_version' do
  before(:each) do
    Facter.clear
  end

  context 'when java present, returns java version' do
    context 'on OpenBSD', with_env: true do
      before(:each) do
        allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('OpenBSD')
      end
      let(:facts) { { operatingsystem: 'OpenBSD' } }

      it do
        expect(Facter::Util::Resolution).to receive(:which).with('java').and_return('/usr/local/jdk-1.7.0/jre/bin/java')
        expect(Facter::Util::Resolution).to receive(:exec).with('java -Xmx12m -version 2>&1').and_return(openjdk_7_output)
        expect(Facter.value(:java_version)).to eq('1.7.0_71')
      end
    end
    context 'when on Darwin' do
      before(:each) do
        allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('Darwin')
      end
      let(:facts) { { operatingsystem: 'Darwin' } }

      it do
        expect(Facter::Util::Resolution).to receive(:exec).with('/usr/libexec/java_home --failfast 2>&1').and_return('/Library/Java/JavaVirtualMachines/jdk1.7.0_71.jdk/Contents/Home')
        expect(Facter::Util::Resolution).to receive(:exec).with('java -Xmx12m -version 2>&1').and_return(jdk_7_hotspot_output)
        expect(Facter.value(:java_version)).to eql '1.7.0_71'
      end
    end
    context 'when on other systems' do
      before(:each) do
        allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('MyOS')
      end
      let(:facts) { { operatingsystem: 'MyOS' } }

      it do
        expect(Facter::Util::Resolution).to receive(:which).with('java').and_return('/path/to/java')
        expect(Facter::Util::Resolution).to receive(:exec).with('java -Xmx12m -version 2>&1').and_return(jdk_7_hotspot_output)
        expect(Facter.value(:java_version)).to eq('1.7.0_71')
      end
    end
  end

  context 'when java not present, returns nil' do
    context 'on OpenBSD', with_env: true do
      before(:each) do
        allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('OpenBSD')
      end
      let(:facts) { { operatingsystem: 'OpenBSD' } }

      it do
        allow(Facter::Util::Resolution).to receive(:exec) # Catch all other calls
        expect(Facter.value(:java_version)).to be_nil
      end
    end
    context 'when on Darwin' do
      before(:each) do
        allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('Darwin')
      end
      let(:facts) { { operatingsystem: 'Darwin' } }

      it do
        expect(Facter::Util::Resolution).to receive(:exec).with('/usr/libexec/java_home --failfast 2>&1').at_least(1).and_return('Unable to find any JVMs matching version "(null)".')
        expect(Facter.value(:java_version)).to be_nil
      end
    end
    context 'when on other systems' do
      before(:each) do
        allow(Facter.fact(:operatingsystem)).to receive(:value).and_return('MyOS')
      end
      let(:facts) { { operatingsystem: 'MyOS' } }

      it do
        expect(Facter::Util::Resolution).to receive(:which).at_least(1).with('java').and_return(false)
        expect(Facter.value(:java_version)).to be_nil
      end
    end
  end
end

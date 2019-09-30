require 'spec_helper'

java_7_path = '/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java'
java_7_home = '/usr/lib/jvm/java-7-openjdk-amd64'
java_8_path = '/usr/lib/jvm/oracle-java8-jre-amd64/bin/java'
java_8_home = '/usr/lib/jvm/oracle-java8-jre-amd64'

def unlink_and_delete(filename)
  if File.symlink?(filename)
    File.unlink(filename)
  end
  return unless File.exist?(filename)
  File.delete(filename)
end

def symlink_and_test(symlink_path, java_home)
  File.symlink(symlink_path, './java_test')
  expect(Facter::Util::Resolution).to receive(:which).with('java').and_return('./java_test')
  expect(File).to receive(:realpath).with('./java_test').and_return(symlink_path)
  expect(Facter.value(:java_default_home)).to eql java_home
end

describe 'java_default_home' do
  before(:each) do
    Facter.clear
    allow(Facter.fact(:kernel)).to receive(:value).once.and_return('Linux')
  end

  context 'when java found in PATH' do
    context 'when java is in /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java' do
      it do
        unlink_and_delete('./java_test')
        symlink_and_test(java_7_path, java_7_home)
        unlink_and_delete('./java_test')
      end
    end

    context 'when java is in /usr/lib/jvm/oracle-java8-jre-amd64/bin/java' do
      it do
        unlink_and_delete('./java_test')
        symlink_and_test(java_8_path, java_8_home)
        unlink_and_delete('./java_test')
      end
    end
  end

  context 'when java not present, return nil' do
    it do
      allow(Facter::Util::Resolution).to receive(:exec) # Catch all other calls
      expect(Facter::Util::Resolution).to receive(:which).with('java').at_least(1).and_return(nil)
      expect(Facter.value(:java_default_home)).to be_nil
    end
  end
end

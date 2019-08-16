require 'spec_helper_acceptance'

describe 'wget class:', unless: UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'wget is expected run successfully' do
    pp = "class { 'wget': }"

    # Apply twice to ensure no errors the second time.
    apply_manifest(pp, catch_failures: true) do |r|
      expect(r.stderr).not_to match(%r{error}i)
    end
    apply_manifest(pp, catch_failures: true) do |r|
      expect(r.stderr).not_to eq(%r{error}i)

      expect(r.exit_code).to be_zero
    end
  end

  context 'package_ensure => present:' do
    it 'runs successfully to ensure package is installed' do
      pp = "class { 'wget': package_ensure => present }"

      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to match(%r{error}i)
      end
    end
  end

  context 'retrievals => hash:' do
    it 'runs successfully and retrieves a web page' do
      pp = "class { 'wget': package_ensure => present, retrievals => {'http://www.apple.com/index.html' => {destination => '/tmp/'} } }"

      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to match(%r{error}i)
      end
      shell('test -e /tmp/index.html')
      shell('rm -f /tmp/index.html')
    end
  end

  context 'package_ensure => absent:' do
    it 'runs successfully to ensure package is uninstalled' do
      pp = "class { 'wget': package_ensure => absent }"

      apply_manifest(pp, catch_failures: true) do |r|
        expect(r.stderr).not_to match(%r{error}i)
      end
    end
  end
end

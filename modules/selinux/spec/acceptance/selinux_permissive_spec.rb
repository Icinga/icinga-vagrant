require 'spec_helper_acceptance'

describe 'selinux::permissive define' do
  context 'ensure present for passwd_t' do
    let(:result) do
      manifest = "selinux::permissive {'passwd_t':}"
      apply_manifest(manifest, catch_failures: true)
    end

    after :all do
      # cleanup
      shell('semanage permissive -d passwd_t', acceptable_exit_codes: [0, 1])
    end
    it 'runs without errors' do
      expect(result.exit_code).to eq 2
    end
    it 'makes passwd_t permissive' do
      shell('semanage permissive -l | grep -q passwd_t')
    end
  end
  context 'purge with ensure present for passwd_t, when kernel_t is permissive' do
    before :all do
      shell('semanage permissive -a kernel_t')
    end
    let(:result) do
      manifest = <<-EOS
      selinux::permissive {'passwd_t':}
      resources {'selinux_permissive': purge => true }
      EOS
      apply_manifest(manifest, catch_failures: true)
    end

    after :all do
      # clean up
      shell('semanage permissive -d passwd_t', acceptable_exit_codes: [0, 1])
      shell('semanage permissive -d kernel_t', acceptable_exit_codes: [0, 1])
    end
    it 'runs without errors' do
      expect(result.exit_code).to eq 2
    end
    it 'purges kernel_t' do
      shell('semanage permissive -l | grep -q kernel_t', acceptable_exit_codes: [1])
    end
    it 'makes passwd_t permissive' do
      shell('semanage permissive -l | grep -q passwd_t')
    end
  end
  context 'ensure absent for kernel_t only, when passwd_t is also permissive' do
    before :all do
      shell('semanage permissive -a kernel_t')
      shell('semanage permissive -a passwd_t')
    end
    let(:result) do
      manifest = "selinux::permissive {'kernel_t': ensure => 'absent'}"
      apply_manifest(manifest, catch_failures: true)
    end

    after :all do
      # clean up
      shell('semanage permissive -d passwd_t', acceptable_exit_codes: [0, 1])
      shell('semanage permissive -d kernel_t', acceptable_exit_codes: [0, 1])
    end
    it 'runs without errors' do
      expect(result.exit_code).to eq 2
    end
    it 'makes kernel_t not permissive' do
      shell('semanage permissive -l | grep -q kernel_t', acceptable_exit_codes: [1])
    end
    it 'does not remove passwd_t' do
      shell('semanage permissive -l | grep -q passwd_t')
    end
  end
end

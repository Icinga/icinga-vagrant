require 'spec_helper_acceptance'

describe 'ini_setting resource' do
  basedir = setup_test_directory

  after :all do
    run_shell("rm #{basedir}/*.ini", expect_failures: true)
  end

  shared_examples 'has_content' do |path, pp, content|
    before :all do
      run_shell("rm #{path}", expect_failures: true)
    end

    it 'applies the manifest twice' do
      idempotent_apply(pp)
    end

    describe file(path) do
      it { is_expected.to be_file }

      describe '#content' do
        subject { super().content }

        it { is_expected.to match content }
      end
    end
  end

  shared_examples 'has_error' do |path, pp, error|
    before :all do
      run_shell("rm #{path}", expect_failures: true)
    end

    it 'applies the manifest and gets a failure message' do
      expect(apply_manifest(pp, expect_failures: true).stderr).to match(error)
    end

    describe file(path) do
      it { is_expected.not_to be_file }
    end
  end

  context 'ensure parameter => present for global and section' do
    pp = <<-EOS
    ini_setting { 'ensure => present for section':
      ensure  => present,
      path    => "#{basedir}/ini_setting.ini",
      section => 'one',
      setting => 'two',
      value   => 'three',
    }
    ini_setting { 'ensure => present for global':
      ensure  => present,
      path    => "#{basedir}/ini_setting.ini",
      section => '',
      setting => 'four',
      value   => 'five',
    }
    EOS

    it_behaves_like 'has_content', "#{basedir}/ini_setting.ini", pp, %r{four = five\R\R\[one\]\Rtwo = three}
  end

  context 'ensure parameter => absent for key/value' do
    before :all do
      ipp = <<-MANIFEST
        file { '#{basedir}/ini_setting.ini':
          content => "four = five \n [one] \n two = three",
          force   => true,
        }
      MANIFEST

      apply_manifest(ipp)
    end

    pp = <<-EOS
    ini_setting { 'ensure => absent for key/value':
      ensure  => absent,
      path    => "#{basedir}/ini_setting.ini",
      section => 'one',
      setting => 'two',
      value   => 'three',
    }
    EOS

    it 'applies the manifest twice' do
      idempotent_apply(pp)
    end

    describe file("#{basedir}/ini_setting.ini") do
      it { is_expected.to be_file }

      describe '#content' do
        subject { super().content }

        it { is_expected.to match %r{four = five} }
        it { is_expected.not_to match %r{\[one\]} }
        it { is_expected.not_to match %r{two = three} }
      end
    end
  end

  context 'ensure parameter => absent for global' do
    before :all do
      ipp = <<-MANIFEST
        file { '#{basedir}/ini_setting.ini':
          content => "four = five\n [one]\n two = three",
          force   => true,
        }
      MANIFEST

      apply_manifest(ipp)
    end

    after :all do
      run_shell("rm #{basedir}/ini_setting.ini", expect_failures: true)
    end

    pp = <<-EOS
    ini_setting { 'ensure => absent for global':
      ensure  => absent,
      path    => "#{basedir}/ini_setting.ini",
      section => '',
      setting => 'four',
      value   => 'five',
    }
    EOS

    it 'applies the manifest twice' do
      idempotent_apply(pp)
    end

    describe file("#{basedir}/ini_setting.ini") do
      it { is_expected.to be_file }

      describe '#content' do
        subject { super().content }

        it { is_expected.not_to match %r{four = five} }
        it { is_expected.to match %r{\[one\]} }
        it { is_expected.to match %r{two = three} }
      end
    end
  end

  describe 'path parameter' do
    context 'path => foo' do
      pp = <<-EOS
        ini_setting { 'path => foo':
          ensure     => present,
          section    => 'one',
          setting    => 'two',
          value      => 'three',
          path       => 'foo',
        }
      EOS

      it_behaves_like 'has_error', 'foo', pp, %r{must be fully qualified}
    end
  end

  describe 'show_diff parameter and logging:' do
    setup_puppet_config_file

    [{ value: 'initial_value', matcher: 'created', show_diff: true },
     { value: 'public_value', matcher: %r{initial_value.*public_value}, show_diff: true },
     { value: 'secret_value', matcher: %r{redacted sensitive information.*redacted sensitive information}, show_diff: false },
     { value: 'md5_value', matcher: %r{\{md5\}881671aa2bbc680bc530c4353125052b.*\{md5\}ed0903a7fa5de7886ca1a7a9ad06cf51}, show_diff: :md5 }].each do |i|
      pp = <<-EOS
          ini_setting { 'test_show_diff':
            ensure      => present,
            section     => 'test',
            setting     => 'something',
            value       => '#{i[:value]}',
            path        => "#{basedir}/test_show_diff.ini",
            show_diff   => #{i[:show_diff]}
          }
      EOS

      context "show_diff => #{i[:show_diff]}" do
        res = apply_manifest(pp, expect_changes: true)
        it 'applies manifest and expects changed value to be logged in proper form' do
          expect(res.stdout).to match(i[:matcher])
        end
        it 'applies manifest and expects changed value to be logged in proper form #optional test' do
          expect(res.stdout).not_to match(i[:value]) unless i[:show_diff] == true
        end
      end
    end
  end

  describe 'values with spaces in the value part at the beginning or at the end' do
    pp = <<-EOS
      ini_setting { 'path => foo':
          ensure     => present,
          section    => 'one',
          setting    => 'two',
          value      => '               123',
          path       => '#{basedir}/ini_setting.ini',
        }
    EOS

    it_behaves_like 'has_content', "#{basedir}/ini_setting.ini", pp, %r{\[one\]\Rtwo = 123}
  end

  describe 'refreshonly' do
    before :each do
      ipp = <<-MANIFEST
        file { '#{basedir}/ini_setting.ini':
          content => "[section1]\n valueinsection1 = 123\",
          force   => true,
        }
      MANIFEST

      apply_manifest(ipp)
    end

    after :each do
      run_shell("rm #{basedir}/ini_setting.ini", expect_failures: true)
    end
    context 'when event is triggered' do
      context 'update setting value' do
        let(:update_value_manifest) do
          <<-EOS
          notify { foo:
            notify => Ini_Setting['updateSetting'],
          }

          ini_setting { "updateSetting":
            ensure => present,
            path => "#{basedir}/ini_setting.ini",
            section => 'section1',
            setting => 'valueinsection1',
            value   => "newValue",
            refreshonly => true,
          }
          EOS
        end

        before(:each) do
          apply_manifest(update_value_manifest, expect_changes: true)
        end

        describe file("#{basedir}/ini_setting.ini") do
          it { is_expected.to be_file }
          describe '#content' do
            subject { super().content }

            it { is_expected.to match %r{valueinsection1 = newValue} }
          end
        end
      end

      context 'remove setting value' do
        let(:remove_setting_manifest) do
          <<-EOS
          notify { foo:
            notify => Ini_Setting['removeSetting'],
          }

          ini_setting { "removeSetting":
            ensure => absent,
            path => "#{basedir}/ini_setting.ini",
            section => 'section1',
            setting => 'valueinsection1',
            refreshonly => true,
          }
          EOS
        end

        before(:each) do
          apply_manifest(remove_setting_manifest, expect_changes: true)
        end

        describe file("#{basedir}/ini_setting.ini") do
          it { is_expected.to be_file }
          describe '#content' do
            subject { super().content }

            it { is_expected.to be_empty }
          end
        end
      end
    end

    context 'when not receiving an event' do
      context 'does not update setting' do
        let(:does_not_update_value_manifest) do
          <<-EOS
          file { "#{basedir}/ini_setting.ini":
            ensure => present,
            notify => Ini_Setting['updateSetting'],
          }
          ini_setting { "updateSetting":
            ensure => present,
            path => "#{basedir}/ini_setting.ini",
            section => 'section1',
            setting => 'valueinsection1',
            value   => "newValue",
            refreshonly => true,
          }
          EOS
        end

        before(:each) do
          apply_manifest(does_not_update_value_manifest, expect_changes: false)
        end

        describe file("#{basedir}/ini_setting.ini") do
          it { is_expected.to be_file }
          describe '#content' do
            subject { super().content }

            it { is_expected.to match %r{valueinsection1 = 123} }
            it { is_expected.to match %r{\[section1\]} }
          end
        end
      end

      context 'does not remove setting' do
        let(:does_not_remove_setting_manifest) do
          <<-EOS
          file { "#{basedir}/ini_setting.ini":
            ensure => present,
            notify => Ini_Setting['removeSetting'],
          }

          ini_setting { "removeSetting":
            ensure => absent,
            path => "#{basedir}/ini_setting.ini",
            section => 'section1',
            setting => 'valueinsection1',
            refreshonly => true,
          }
          EOS
        end

        before(:each) do
          apply_manifest(does_not_remove_setting_manifest, expect_changes: false)
        end

        describe file("#{basedir}/ini_setting.ini") do
          it { is_expected.to be_file }
          describe '#content' do
            subject { super().content }

            it { is_expected.not_to be_empty }
            it { is_expected.to match %r{valueinsection1 = 123} }
            it { is_expected.to match %r{\[section1\]} }
          end
        end
      end
    end
  end
end

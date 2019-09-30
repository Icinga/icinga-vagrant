require 'spec_helper'

describe 'wget::retrieve' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let :pre_condition do
        'class { "wget": }'
      end

      let(:title) { 'test' }

      let(:params) do
        {
          source: 'http://localhost/source',
          destination: destination,
        }
      end

      let(:destination) { '/tmp/dest' }

      context 'with default params', :compile do
        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => "wget --no-verbose --output-document=\"#{destination}\" \"http://localhost/source\"",
            'environment' => [],
          )
        }
      end

      context 'with user', :compile do
        let(:params) do
          super().merge(
            execuser: 'testuser',
          )
        end

        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => "wget --no-verbose --output-document=\"#{destination}\" \"http://localhost/source\"",
            'user' => 'testuser',
            'environment' => [],
          )
        }
      end

      context 'with authentication', :compile do
        let(:params) do
          super().merge(
            user: 'myuser',
            password: 'mypassword',
          )
        end

        context 'with default params' do
          it {
            is_expected.to contain_exec('wget-test').with(
              'command'     => "wget --no-verbose --user=myuser --output-document=\"#{destination}\" \"http://localhost/source\"",
              'environment' => ["WGETRC=#{destination}.wgetrc"],
            )
          }

          it {
            is_expected.to contain_file("#{destination}.wgetrc").with_content('password=mypassword')
          }
        end

        context 'with user', :compile do
          let(:params) do
            super().merge(
              execuser: 'testuser',
            )
          end

          it {
            is_expected.to contain_exec('wget-test').with(
              'command' => "wget --no-verbose --user=myuser --output-document=\"#{destination}\" \"http://localhost/source\"",
              'user' => 'testuser',
              'environment' => ["WGETRC=#{destination}.wgetrc"],
            )
          }
        end

        context 'using proxy', :compile do
          let(:params) do
            super().merge(
              http_proxy: 'http://proxy:1000',
              https_proxy: 'https://proxy:1000',
            )
          end

          it {
            is_expected.to contain_exec('wget-test').with(
              'command'     => "wget --no-verbose --user=myuser --output-document=\"#{destination}\" \"http://localhost/source\"",
              'environment' => ['HTTP_PROXY=http://proxy:1000', 'http_proxy=http://proxy:1000', 'HTTPS_PROXY=https://proxy:1000', 'https_proxy=https://proxy:1000', "WGETRC=#{destination}.wgetrc"],
            )
          }

          it {
            is_expected.to contain_file("#{destination}.wgetrc").with_content('password=mypassword')
          }
        end
      end

      context 'with cache', :compile do
        let(:params) do
          super().merge(
            cache_dir: '/tmp/cache',
            execuser: 'testuser',
          )
        end

        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => 'wget --no-verbose -N -P "/tmp/cache" "http://localhost/source"',
            'environment' => [],
          )
        }

        it {
          is_expected.to contain_file(destination.to_s).with(
            'ensure'  => 'file',
            'source'  => '/tmp/cache/source',
            'owner'   => 'testuser',
          )
        }
      end

      context 'with cache file', :compile do
        let(:params) do
          super().merge(
            cache_dir: '/tmp/cache',
            cache_file: 'newsource',
            execuser: 'testuser',
          )
        end

        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => 'wget --no-verbose -N -P "/tmp/cache" "http://localhost/source"',
            'environment' => [],
          )
        }

        it {
          is_expected.to contain_file(destination.to_s).with(
            'ensure'  => 'file',
            'source'  => '/tmp/cache/newsource',
            'owner'   => 'testuser',
          )
        }
      end

      context 'with multiple headers', :compile do
        let(:params) do
          super().merge(
            headers: ['header1', 'header2'],
          )
        end

        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => "wget --no-verbose --header \"header1\" --header \"header2\" --output-document=\"#{destination}\" \"http://localhost/source\"",
            'environment' => [],
          )
        }
      end

      context 'with no-cookies', :compile do
        let(:params) do
          super().merge(
            no_cookies: true,
          )
        end

        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => "wget --no-verbose --no-cookies --output-document=\"#{destination}\" \"http://localhost/source\"",
            'environment' => [],
          )
        }
      end

      context 'with flags', :compile do
        let(:params) do
          super().merge(
            flags: ['--flag1', '--flag2'],
          )
        end

        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => "wget --no-verbose --output-document=\"#{destination}\" --flag1 --flag2 \"http://localhost/source\"",
            'environment' => [],
          )
        }
      end

      context 'with source_hash', :compile do
        let(:params) do
          super().merge(
            source_hash: 'd41d8cd98f00b204e9800998ecf8427e',
          )
        end

        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => "wget --no-verbose --output-document=\"#{destination}\" \"http://localhost/source\" && echo 'd41d8cd98f00b204e9800998ecf8427e  #{destination}' | md5sum -c --quiet",
            'environment' => [],
          )
        }

        it {
          is_expected.to contain_exec('wget-source_hash-check-test').with(
            'command' => "test ! -e '#{destination}' || rm #{destination}",
            'unless'  => "echo 'd41d8cd98f00b204e9800998ecf8427e  #{destination}' | md5sum -c --quiet",
          )
        }
      end

      context 'download to dir', :compile do
        let(:params) do
          super().merge(
            destination: '/tmp/dest/',
          )
        end

        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => "wget --no-verbose --output-document=\"#{destination}//source\" \"http://localhost/source\"",
            'environment' => [],
          )
        }
      end

      context 'with unless', :compile do
        let(:params) do
          super().merge(
            unless: "test $(ls -A #{destination} | head -1 2>/dev/null)",
          )
        end

        it {
          is_expected.to contain_exec('wget-test').with(
            'command' => "wget --no-verbose --output-document=\"#{destination}\" \"http://localhost/source\"",
            'unless'  => "test $(ls -A #{destination} | head -1 2>/dev/null)",
          )
        }
      end
    end
  end
end

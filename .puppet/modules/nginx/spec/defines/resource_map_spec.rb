require 'spec_helper'

describe 'nginx::resource::map' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let :title do
        'backend_pool'
      end

      let :default_params do
        {
          string: '$uri',
          default: 'pool_a',
          mappings: {
            'foo' => 'pool_b',
            'bar' => 'pool_c',
            'baz' => 'pool_d'
          }
        }
      end

      let :pre_condition do
        [
          'include ::nginx'
        ]
      end

      describe 'os-independent items' do
        describe 'basic assumptions' do
          let(:params) { default_params }

          it { is_expected.to contain_file("/etc/nginx/conf.d/#{title}-map.conf").that_requires('File[/etc/nginx/conf.d]') }
          it do
            is_expected.to contain_file("/etc/nginx/conf.d/#{title}-map.conf").with(
              'owner' => 'root',
              'group'   => 'root',
              'mode'    => '0644',
              'ensure'  => 'file',
              'content' => %r{map \$uri \$#{title}}
            )
          end
        end

        describe 'map.conf template content' do
          [
            {
              title: 'should set hostnames',
              attr: 'hostnames',
              value: true,
              match: '  hostnames;'
            },
            {
              title: 'should not contain includes',
              attr: 'include_files',
              value: [],
              notmatch: '  include ;'
            },
            {
              title: 'should contain includes',
              attr: 'include_files',
              value: ['/etc/includes/includes.map'],
              match: '  include /etc/includes/includes.map;'
            },
            {
              title: 'should contain multiple includes',
              attr: 'include_files',
              value: [
                '/etc/includes/A.map',
                '/etc/includes/B.map',
                '/etc/includes/C.map'
              ],
              match: [
                '  include /etc/includes/A.map;',
                '  include /etc/includes/B.map;',
                '  include /etc/includes/C.map;'
              ]
            },
            {
              title: 'should set default',
              attr: 'default',
              value: 'pool_a',
              match: ['  default pool_a;']
            },
            {
              title: 'should contain ordered mappings when supplied as a hash',
              attr: 'mappings',
              value: {
                'foo' => 'pool_b',
                'bar' => 'pool_c',
                'baz' => 'pool_d'
              },
              match: [
                '  foo pool_b;',
                '  bar pool_c;',
                '  baz pool_d;'
              ]
            },
            {
              title: 'should contain mappings in input order when supplied as an array of hashes',
              attr:  'mappings',
              value: [
                { 'key' => 'foo', 'value' => 'pool_b' },
                { 'key' => 'bar', 'value' => 'pool_c' },
                { 'key' => 'baz', 'value' => 'pool_d' }
              ],
              match: [
                '  foo pool_b;',
                '  bar pool_c;',
                '  baz pool_d;'
              ]
            }
          ].each do |param|
            context "when #{param[:attr]} is #{param[:value]}" do
              let(:params) { default_params.merge(param[:attr].to_sym => param[:value]) }

              it { is_expected.to contain_file("/etc/nginx/conf.d/#{title}-map.conf").with_mode('0644') }
              it param[:title] do
                verify_contents(catalogue, "/etc/nginx/conf.d/#{title}-map.conf", Array(param[:match]))
                Array(param[:notmatch]).each do |item|
                  is_expected.to contain_file("/etc/nginx/conf.d/#{title}-map.conf").without_content(item)
                end
              end
            end
          end

          context 'when ensure => absent' do
            let :params do
              default_params.merge(
                ensure: 'absent'
              )
            end

            it { is_expected.to contain_file("/etc/nginx/conf.d/#{title}-map.conf").with_ensure('absent') }
          end
        end
      end
    end
  end
end

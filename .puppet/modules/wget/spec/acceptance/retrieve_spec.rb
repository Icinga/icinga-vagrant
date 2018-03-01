require 'spec_helper_acceptance'

describe 'wget::retrieve' do

  let(:wget_manifest) { "class { 'wget': }" }
  let(:manifest) { wget_manifest }

  before do
    shell "rm -f /tmp/index*"
  end

  context 'when running as root' do
    let(:manifest) { super() + %Q(
        wget::retrieve { "download Google's index":
          source      => 'http://www.google.com/index.html',
          destination => '/tmp/index.html',
          timeout     => 0,
          verbose     => false,
        }
      )
    }

    it 'should be idempotent' do
      apply_manifest(manifest, :catch_failures => true)
      apply_manifest(manifest, :catch_changes => true)
      shell('test -e /tmp/index.html')
      shell('rm -f /tmp/index.html')
    end
  end

end

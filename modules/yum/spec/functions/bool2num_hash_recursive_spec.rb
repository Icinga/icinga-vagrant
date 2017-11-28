require 'spec_helper'

describe 'yum::bool2num_hash_recursive' do
  let(:flat_hash) { { 'a' => true, 'b' => false, 'c' => 'c' } }
  let(:nested_hash) do
    {
      'a' => {
        'aa'  => true, 'ab'  => false, 'ac'  => 'c',
        'aaa' => true, 'aab' => false, 'aac' => 'c'
      },
      'b' => { 'ba' => true, 'bb' => false, 'bc' => 'c' },
      'c' => true,
      'd' => false,
      'e' => 5
    }
  end

  it 'appropriately modifies a simple, flat hash' do
    is_expected.to run.with_params(flat_hash).and_return('a' => 1, 'b' => 0, 'c' => 'c')
  end

  it 'appropriately modifies a nested hash' do
    is_expected.to run.with_params(nested_hash).
      and_return(
        'a' => {
          'aa'  => 1, 'ab'  => 0, 'ac'  => 'c',
          'aaa' => 1, 'aab' => 0, 'aac' => 'c'
        },
        'b' => { 'ba' => 1, 'bb' => 0, 'bc' => 'c' },
        'c' => 1,
        'd' => 0,
        'e' => 5
      )
  end

  it 'fails on an array' do
    is_expected.to run.with_params([true, false]).and_raise_error(Puppet::Error)
  end
end

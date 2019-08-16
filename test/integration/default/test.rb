describe file('/tmp/demo1') do
  it { should be_file }
  its('content') { should match(%r{bar: two, foo: one}) }
end

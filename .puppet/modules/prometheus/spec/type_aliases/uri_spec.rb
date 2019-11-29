require 'spec_helper'

describe 'Prometheus::Uri' do
  describe 'accepts http, https, and case-sensitive aws s3 uris' do
    [
      'http://www.download.com',
      'HTTP://www.download.com',
      'Https://service.io',
      'https://service.io',
      's3://bucket-name/path',
      's3://bucket/path/to/file.txt'
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'rejects other values' do
    [
      '',
      'htpt://www.download.com',
      'httds://service.io',
      'S3://bucket-name/path',
      3,
      's3-bucket-name/path'
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end

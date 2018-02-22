#! /usr/bin/env ruby
require 'spec_helper'

ini_setting = Puppet::Type.type(:ini_setting)

describe ini_setting do
  describe 'path validation' do
    subject { lambda { described_class.new(:name => 'foo', :path => path) } }

    context 'on posix platforms' do
      before(:each) { Puppet.features.stub(:posix?) { true } }
      before(:each) { Puppet.features.stub(:microsoft_windows?) { false } }
      before(:each) { Puppet::Util::Platform.stub(:windows?) { false } }

      context 'with an absolute path' do
        let(:path) { '/absolute/path' }
        it { should_not raise_exception }
      end

      context 'with a relative path' do
        let(:path) { 'relative/path' }
        it { should raise_exception }
      end
    end

    context 'on windows platforms' do
      before(:each) { Puppet.features.stub(:posix?) { false } }
      before(:each) { Puppet.features.stub(:microsoft_windows?) { true } }
      before(:each) { Puppet::Util::Platform.stub(:windows?) { true } }

      context 'with an absolute path with front slashes' do
        let(:path) { 'c:/absolute/path' }
        it { should_not raise_exception }
      end

      context 'with an absolute path with backslashes' do
        let(:path) { 'c:\absolute\path' }
        it { should_not raise_exception }
      end

      context 'with an absolute path with mixed slashes' do
        let(:path) { 'c:/absolute\path' }
        it { should_not raise_exception }
      end

      context 'with a relative path with front slashes' do
        let(:path) { 'relative/path' }
        it { should raise_exception }
      end

      context 'with a relative path with back slashes' do
        let(:path) { 'relative\path' }
        it { should raise_exception }
      end
    end
  end

  [true, false].product([true, false, "true", "false", "md5", :md5]).each do |cfg, param|
    describe "when Puppet[:show_diff] is #{cfg} and show_diff => #{param}" do

      before do
        Puppet[:show_diff] = cfg
        @value = described_class.new(:name => 'foo', :value => 'whatever', :show_diff => param).property(:value)
      end

      if (cfg and [true, "true"].include? param)
        it "should display diff" do
          expect(@value.change_to_s('not_secret','at_all')).to include('not_secret','at_all')
        end

        it "should tell current value" do
          expect(@value.is_to_s('not_secret_at_all')).to eq('not_secret_at_all')
        end

        it "should tell new value" do
          expect(@value.should_to_s('not_secret_at_all')).to eq('not_secret_at_all')
        end
      elsif (cfg and ["md5", :md5].include? param)
        it "should tell correct md5 hash for value" do
          expect(@value.change_to_s('not_secret','at_all')).to include('e9e8db547f8960ef32dbc34029735564','46cd73a9509ba78c39f05faf078a8cbe')
          expect(@value.change_to_s('not_secret','at_all')).not_to include('not_secret')
          expect(@value.change_to_s('not_secret','at_all')).not_to include('at_all')
        end

        it "should tell md5 of current value, but not value itself" do
          expect(@value.is_to_s('not_secret_at_all')).to eq('{md5}218fde79f501b8ab8d212f1059bb857f')
          expect(@value.is_to_s('not_secret_at_all')).not_to include('not_secret_at_all')
        end

        it "should tell md5 of new value, but not value itself" do
          expect(@value.should_to_s('not_secret_at_all')).to eq('{md5}218fde79f501b8ab8d212f1059bb857f')
          expect(@value.should_to_s('not_secret_at_all')).not_to include('not_secret_at_all')
        end
      else
        it "should not tell any actual values" do
          expect(@value.change_to_s('not_secret','at_all')).to include('[redacted sensitive information]')
          expect(@value.change_to_s('not_secret','at_all')).not_to include('not_secret')
          expect(@value.change_to_s('not_secret','at_all')).not_to include('at_all')
        end

        it "should not tell current value" do
          expect(@value.is_to_s('not_secret_at_all')).to eq('[redacted sensitive information]')
          expect(@value.is_to_s('not_secret_at_all')).not_to include('not_secret_at_all')
        end

        it "should not tell new value" do
          expect(@value.should_to_s('not_secret_at_all')).to eq('[redacted sensitive information]')
          expect(@value.should_to_s('not_secret_at_all')).not_to include('not_secret_at_all')
        end
      end
    end
  end
end

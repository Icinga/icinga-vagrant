# frozen_string_literal: true
notification :tmux, display_message: true

guard :bundler do
  watch('Gemfile')
end

guard 'rake', :task => 'test' do
  watch(%r{^manifests\/(.+)\.pp$})
end

guard :rspec, :cmd => 'rspec' do
  watch(%r{^spec\/(classes|templates|unit)\/(.+)\_spec.rb$})
  watch(%r{^templates\/.*\/(.*)$}) { |m| "spec/templates/#{m[1]}_spec.rb" }
  watch(%r{^lib\/puppet\/(.*)[.]rb$}) { |m| "spec/unit/#{m[1]}_spec.rb" }
end

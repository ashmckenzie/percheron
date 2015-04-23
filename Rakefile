require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cane/rake_task'
require 'rubocop/rake_task'

desc 'Run cane, rubocop, unit and integration tests'
task test: %w(test:cane test:rubocop spec:unit spec:integration)

namespace :test do
  desc 'Run cane'
  Cane::RakeTask.new(:cane)

  desc 'Run RuboCop'
  RuboCop::RakeTask.new
end

RSpec::Core::RakeTask.new('spec') do |config|
  config.pattern = './spec/**{,/*/**}/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:unit') do |config|
  config.pattern = './spec/unit/**{,/*/**}/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:integration') do |config|
  config.pattern = './spec/integration/**{,/*/**}/*_spec.rb'
end

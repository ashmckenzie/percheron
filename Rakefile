require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'cane/rake_task'
require 'rubocop/rake_task'

desc 'Run cane, RuboCop, unit and integration tests'
task test: %w(test:style spec)

namespace :test do
  desc 'Run cane'
  Cane::RakeTask.new(:cane)

  desc 'Run RuboCop'
  RuboCop::RakeTask.new

  desc 'Run cane and RuboCop'
  task style: %w(test:cane test:rubocop)
end

desc 'Run unit and integration specs'
task spec: %w(spec:unit spec:integration)

RSpec::Core::RakeTask.new('spec:unit') do |config|
  config.pattern = './spec/unit/**/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:integration') do |config|
  config.pattern = './spec/integration/*_spec.rb'
end

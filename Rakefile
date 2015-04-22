require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new('spec') do |config|
  config.pattern = './spec/**{,/*/**}/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:unit') do |config|
  config.pattern = './spec/unit/**{,/*/**}/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:integration') do |config|
  config.pattern = './spec/integration/**{,/*/**}/*_spec.rb'
end

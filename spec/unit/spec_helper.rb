require 'climate_control'
require 'timecop'

begin
  require 'pry-byebug'
rescue LoadError
  $stderr.puts('pry-byebug not installed.')
end

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.start

base_directory = File.expand_path('../../..', __FILE__)

$LOAD_PATH.unshift(File.join(base_directory, 'lib'))
Dir[File.join(base_directory, 'spec', 'unit', 'support', '**', '*.rb')].sort.each { |f| require(f) }

RSpec.configure do |config|
  config.filter_run_excluding broken: true
  config.before(:all) do
    Dir.chdir(base_directory)
  end
end

require 'percheron'

def with_modified_env(options, &block)
  ClimateControl.modify(options, &block)
end

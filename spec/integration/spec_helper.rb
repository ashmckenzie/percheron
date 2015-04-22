require 'awesome_print'
require 'pry-byebug'
require 'timecop'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)

Dir['./spec/integration/support/**/*.rb'].sort.each { |f| require(f) }

RSpec.configure do |config|
  config.filter_run_excluding broken: true
end

require 'percheron'
require 'percheron/commands'
require 'percheron/logger'

begin
  Percheron::Config.load!('./spec/integration/support/.percheron.yml')
  Docker.version
rescue Excon::Errors::SocketError, Docker::Error::TimeoutError
  puts 'ERROR: Docker does not appear to be running?'
  exit(1)
end

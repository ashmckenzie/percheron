require 'awesome_print'
require 'pry-byebug'
require 'timecop'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)

Dir['./spec/unit/support/**/*.rb'].sort.each { |f| require(f) }

RSpec.configure do |config|
  config.filter_run_excluding broken: true
end

require 'percheron'

require 'awesome_print'
require 'timecop'

begin
  require 'pry-byebug'
rescue LoadError
  $stderr.puts('pry-debug not installed.')
end

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

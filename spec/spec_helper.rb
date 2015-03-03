require 'pry-byebug'
require 'timecop'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

Dir["./spec/support/**/*.rb"].sort.each { |f| require f}

require 'percheron'

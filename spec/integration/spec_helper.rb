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

$LOAD_PATH.unshift File.expand_path('../../../lib', __FILE__)

Dir['./spec/integration/support/**/*.rb'].sort.each { |f| require(f) }

support_directory = File.expand_path('../support', __FILE__)

RSpec.configure do |config|
  config.filter_run_excluding broken: true
  config.before(:all) do
    Dir.chdir(support_directory)
    cleanup!
  end
  config.after(:all) do
    $logger = $metastore = nil
    cleanup!
  end
end

require 'percheron'
require 'percheron/commands'
require 'percheron/logger'

begin
  Percheron::Config.load!(File.join(support_directory, '.percheron.yml')).tap do |c|
    Percheron::Connection.load!(c)
  end
  Docker.version
rescue Excon::Errors::SocketError, Docker::Error::TimeoutError
  puts 'ERROR: Docker does not appear to be running?'
  exit(1)
end

def cleanup!
  cleanup_units!
  cleanup_images!
end

def cleanup_units!
  %w(percheron-test_base percheron-test_app1 percheron-test_app2 percheron-test_app3 ).each do |name|
    begin
      Docker::Container.get(name).tap { |c| c.stop! && c.remove(force: true) }
    rescue Docker::Error::NotFoundError
      nil
    end
  end
end

def cleanup_images!
  %w(busybox:ubuntu-14.04 percheron-test_base:9.9.9 percheron-test_app1:9.9.9 percheron-test_app2:9.9.9).each do |name|
    begin
      Docker::Image.get(name).tap { |i| i.remove(force: true) }
    rescue Docker::Error::NotFoundError
      nil
    end
  end
end

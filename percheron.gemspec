# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'percheron/version'

Gem::Specification.new do |spec|
  spec.name          = 'percheron'
  spec.version       = Percheron::VERSION
  spec.authors       = [ 'Ash McKenzie' ]
  spec.email         = [ 'ash@the-rebellion.net' ]

  spec.summary       = 'Organise your Docker containers with muscle and intelligence'
  spec.homepage      = 'https://github.com/ashmckenzie/percheron'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = [ 'lib' ]

  spec.add_runtime_dependency 'clamp', '~> 1.0.0'
  spec.add_runtime_dependency 'docker-api', '~> 1.0'
  spec.add_runtime_dependency 'hashie', '~> 3.4.0'
  spec.add_runtime_dependency 'highline', '~> 1.7.1'
  spec.add_runtime_dependency 'liquid', '~> 3.0.0'
  spec.add_runtime_dependency 'metastore', '~> 0.3.0'
  spec.add_runtime_dependency 'naught', '~> 1.0.0'
  spec.add_runtime_dependency 'ruby-graphviz', '~> 1.2.0'
  spec.add_runtime_dependency 'semantic', '~> 1.4.0'
  spec.add_runtime_dependency 'terminal-table', '~> 1.5.0'

  spec.add_development_dependency 'bundler', '~> 1.10.0'
  spec.add_development_dependency 'cane', '~> 2.6.0'
  spec.add_development_dependency 'climate_control', '~> 0.0.3'
  spec.add_development_dependency 'guard-rspec', '~> 4.6.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.2.0'
  spec.add_development_dependency 'rake', '~> 10.4.0'
  spec.add_development_dependency 'rspec', '~> 3.3.0'
  spec.add_development_dependency 'rubocop', '~> 0.33.0'
  spec.add_development_dependency 'simplecov', '~> 0.10.0'
  spec.add_development_dependency 'timecop', '~> 0.8.0'
end

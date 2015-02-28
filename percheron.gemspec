# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'percheron/version'

Gem::Specification.new do |spec|
  spec.name          = 'percheron'
  spec.version       = Percheron::VERSION
  spec.authors       = [ 'Ash McKenzie' ]
  spec.email         = [ 'ash@the-rebellion.net' ]

  spec.summary       = %q{Organise your Docker containers with muscle and intelligence}
  spec.homepage      = 'https://github.com/ashmckenzie/percheron'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = [ 'lib' ]

  spec.add_runtime_dependency 'clamp', '~> 0.6'
  spec.add_runtime_dependency 'docker-api', '~> 1.13'
  spec.add_runtime_dependency 'hashie', '~> 3.2'
  spec.add_runtime_dependency 'terminal-table', '~> 1.4'
  spec.add_runtime_dependency 'naught', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.9'
end

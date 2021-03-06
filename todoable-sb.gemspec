# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'todoable/version'

Gem::Specification.new do |spec|
  spec.name          = 'todoable-sb'
  spec.version       = Todoable::VERSION
  spec.authors       = ['Sam Bauch']
  spec.email         = ['sbauch@gmail.com']

  spec.summary       = "Sam Bauch's take home assignment for Teachable"
  spec.homepage      = "https://github.com/sbauch/todoable-sb"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.7.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov', '~> 0.15.1'
  spec.add_development_dependency 'sinatra', '~> 2.0.0'
  spec.add_development_dependency 'timecop', '~> 0.9.1'
  spec.add_development_dependency 'webmock', '~> 3.1.0'
  spec.add_dependency 'httparty', '~> 0.15.6'
end


lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oxr/version'

Gem::Specification.new do |spec|
  spec.name          = 'oxr'
  spec.version       = OXR::VERSION
  spec.authors       = ['John Parker']
  spec.email         = ['jparker@urgetopunt.com']

  spec.summary       = 'Interface for Open Exchange Rates API.'
  spec.description   = 'A ruby interface to the Open Exchange Rates API.'
  spec.homepage      = 'https://github.com/jparker/oxr'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.add_development_dependency 'bundler', '>= 1.17'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'webmock', '~> 3.0'

  spec.add_dependency 'json'
end

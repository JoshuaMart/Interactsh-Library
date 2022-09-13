# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'interactsh'
  spec.version       = '0.9'
  spec.authors       = ['Joshua MARTINELLE']
  spec.email         = ['contact@jomar.fr']
  spec.summary       = 'Interactsh Ruby Library'
  spec.homepage      = 'https://rubygems.org/gems/interactsh'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.1'

  spec.add_dependency('ruby_xid', '~> 1.0.7', '>= 1.0.7')
  spec.add_dependency('typhoeus', '~> 1.4', '>= 1.4.0')

  spec.files = Dir['lib/**/*.rb']
end

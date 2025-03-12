# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'interactsh'
  spec.version       = '0.9.7'
  spec.authors       = ['Joshua MARTINELLE']
  spec.email         = ['contact@jomar.fr']
  spec.summary       = 'Interactsh Ruby Library'
  spec.homepage      = 'https://github.com/JoshuaMart/Interactsh-Library'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1.6'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/JoshuaMart/Interactsh-Library',
    'homepage_uri' => 'https://github.com/JoshuaMart/Interactsh-Library',
    'github_repo' => 'https://github.com/JoshuaMart/Interactsh-Library',
    'rubygems_mfa_required' => 'true'
  }

  spec.add_dependency('jose', '~> 1.2', '>= 1.2.0')
  spec.add_dependency('ruby_xid', '~> 1.0', '>= 1.0.7')

  spec.files = Dir['lib/**/*.rb']
end

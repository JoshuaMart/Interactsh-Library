# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'interactsh'
  spec.version       = '0.9.6'
  spec.authors       = ['Joshua MARTINELLE']
  spec.email         = ['contact@jomar.fr']
  spec.summary       = 'Interactsh Ruby Library'
  spec.homepage      = 'https://github.com/JoshuaMart/Interactsh-Library'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.1'

  spec.metadata = { 
    "source_code_uri" => "https://github.com/JoshuaMart/Interactsh-Library",
    "homepage_uri" => "https://github.com/JoshuaMart/Interactsh-Library",
    "github_repo" => "https://github.com/JoshuaMart/Interactsh-Library"
  }

  spec.add_dependency('jose', '~> 1.1', '>= 1.1.3')
  spec.add_dependency('ruby_xid', '~> 1.0', '>= 1.0.7')
  spec.add_dependency('securerandom', '~> 0.2.0')
  spec.add_dependency('typhoeus', '~> 1.4', '>= 1.4.0')

  spec.files = Dir['lib/**/*.rb']
end

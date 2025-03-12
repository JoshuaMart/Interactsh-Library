
# InteractSH-Library

<p align="center">
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-_red.svg"></a>
    <a href="#"><img src="https://img.shields.io/badge/gem-v0.9.7-blue"></a>
    <a href="https://codeclimate.com/github/EasyRecon/Interactsh-Library/maintainability"><img src="https://api.codeclimate.com/v1/badges/34bf2eae63b2cee4b87e/maintainability" /></a>
</p>

Ruby library for [Interactsh](https://github.com/projectdiscovery/interactsh)

## Installation
```
gem install interactsh
```

## Available method
```ruby
Interactsh::Client.new # => Initialize a new InteractSH class | [Object]
Interactsh::Client.new_domain # => Generate a new domain | [String]
Interactsh::Client.poll # => Retrieves data from the server for a specific domain | [Hash]
```

### Working with custom server
`Interactsh.new` accepts your custom domain as an argument. See [Custom Interactsh Server Installation](https://github.com/projectdiscovery/interactsh#interactsh-server)
```ruby
Interactsh::Client.new('domain.tld')
Interactsh::Client.new('domain.tld', 'your-secret-token')
```

## Usage example :
```ruby
require 'interactsh'
require 'typhoeus'

# Initialization
interactsh = Interactsh::Client.new

# Simulate interaction
domain = interactsh.new_domain
request = Typhoeus::Request.new(domain)
request.run

# We get the the different interactions
datas = interactsh.poll(domain)
datas.each do |data|
  puts "Request type : '#{data['protocol']}' from '#{data['remote-address']}' at #{data['timestamp']}"
end
```

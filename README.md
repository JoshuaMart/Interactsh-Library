
# InteractSH-Library

<p align="center">
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-_red.svg"></a>
    <a href="#"><img src="https://img.shields.io/badge/gem-v1.1.0-blue"></a>
    <a href="https://codeclimate.com/github/JoshuaMart/Interactsh-Library/maintainability"><img src="https://api.codeclimate.com/v1/badges/1d0e883c2d4af5834a0a/maintainability" /></a>
</p>

Ruby library for [Interactsh](https://github.com/projectdiscovery/interactsh)

## Installation
```
gem install interactsh
```

## Available method
```ruby
Interactsh::Client.new        # => Initialize a new InteractSH class | [Object]
Interactsh::Client.new_domain # => Generate a new domain | [String]
Interactsh::Client.poll       # => Retrieves data from the server for a specific domain | [Hash]
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
require 'net/http'

# Initialize client
client = Interactsh::Client.new

# Generate unique interaction domain
domain = client.new_domain
puts "Generated domain: #{domain}"

# Simulate an HTTP request to the domain
uri = URI("http://#{domain}")
response = Net::HTTP.get_response(uri)
puts "Made HTTP request to #{domain}"

# Poll for interactions
puts "Polling for interactions..."
interactions = client.poll(domain)

# Process interactions
interactions.each do |interaction|
  puts "Request type: '#{interaction['protocol']}' from '#{interaction['remote-address']}' at #{interaction['timestamp']}"
  puts "Full interaction data: #{interaction.inspect}"
end
```

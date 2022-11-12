
# InteractSH-Library

<p align="center">  
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-_red.svg"></a>  
    <a href="#"><img src="https://img.shields.io/badge/gem-v0.9-blue"></a>  
    <a href="https://codeclimate.com/github/EasyRecon/Interactsh-Library"><img src="https://codeclimate.com/github/EasyRecon/Interactsh-Library.png"></a>
</p>

Ruby library for [Interactsh](https://github.com/projectdiscovery/interactsh)

## Installation
```
gem install interactsh
```

## Available method
```ruby
Interactsh.new # => Initialize a new domain on the interact.sh server | [Object]
Interactsh.domain # => Displays the created domain | [String]
Interactsh.poll # => Retrieves data from the server | [Hash]
```

### Working with custom server
`Interactsh.new` accepts your custom domain as an argument. See [Custom Interactsh Server Installation](https://github.com/projectdiscovery/interactsh#interactsh-server)
```ruby
Interactsh.new('domain.tld')
Interactsh.new('domain.tld', 'your-secret-token')
```

## Usage example :
```ruby
require 'interactsh'
require 'typhoeus'

# Initialization
interactsh = Interactsh.new

# Simulate interaction
domain = interactsh.get_domain
request = Typhoeus::Request.new(domain)
request.run

# We get the the different interactions
datas = interactsh.poll(domain)
datas.each do |data|
  puts "Request type : '#{data['protocol']}' from '#{data['remote-address']}' at #{data['timestamp']}"
end
```

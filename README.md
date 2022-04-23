# Interactsh ![Gem Version](https://img.shields.io/badge/gem-v0.0.2-blue)
Ruby library for [Interactsh](https://github.com/projectdiscovery/interactsh)

## Installation
```
gem install interactsh-{v}.gem
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
Interactsh = Interactsh.new

# Simulate interaction
domain = Interactsh.get_domain
request = Typhoeus::Request.new(domain)
request.run

# We get the the different interactions
datas = Interactsh.poll
datas.each do |data|
	puts "Request type : '#{data['protocol']}' from '#{data['remote-address']}' at #{data['timestamp']}"
end
```

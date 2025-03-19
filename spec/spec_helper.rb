# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.output_directory = 'coverage'
SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true

SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter

SimpleCov.start do
  add_filter '/spec/'
  add_group 'Core', 'lib/interactsh.rb'
  add_group 'Client', 'lib/interactsh/client.rb'
  add_group 'Crypto', 'lib/interactsh/crypto.rb'
  add_group 'HTTP', 'lib/interactsh/http_client.rb'
  add_group 'Utils', 'lib/interactsh/utils.rb'
  add_group 'Errors', 'lib/interactsh/errors.rb'
end

require 'interactsh'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.warnings = true
  config.order = :random
  Kernel.srand config.seed
end

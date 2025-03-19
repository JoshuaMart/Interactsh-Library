# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Interactsh module' do
  it 'loads all the required dependencies' do
    # These files should be loaded via lib/interactsh.rb
    expect(defined?(OpenSSL)).to eq('constant')
    expect(defined?(JOSE)).to eq('constant')
    expect(defined?(StringIO)).to eq('constant')
    expect(defined?(Base64)).to eq('constant')
    expect(defined?(JSON)).to eq('constant')
    expect(defined?(Xid)).to eq('constant')
    expect(defined?(Net::HTTP)).to eq('constant')
    expect(defined?(URI)).to eq('constant')
  end

  it 'has all the expected components defined' do
    expect(defined?(Interactsh::Client)).to eq('constant')
    expect(defined?(Interactsh::Crypto)).to eq('constant')
    expect(defined?(Interactsh::HttpClient)).to eq('constant')
    expect(defined?(Interactsh::Utils)).to eq('constant')
    expect(defined?(Interactsh::Error)).to eq('constant')
    expect(defined?(Interactsh::RegistrationError)).to eq('constant')
    expect(defined?(Interactsh::PollError)).to eq('constant')
    expect(defined?(Interactsh::DecryptionError)).to eq('constant')
    expect(defined?(Interactsh::HTTPRequestError)).to eq('constant')
  end

  context 'workflow examples' do
    let(:client) { Interactsh::Client.new('oast.me', 'test-token') }

    before do
      # Mock everything to avoid actual HTTP requests
      allow_any_instance_of(OpenSSL::PKey::RSA).to receive(:public_key).and_return(double(to_pem: 'test-public-key'))
      allow(Base64).to receive(:strict_encode64).and_return('encoded-public-key')
      allow(Interactsh::Utils).to receive(:generate_uuid).and_return('test-secret')
      allow(Interactsh::Utils).to receive(:generate_random_string).and_return('random-string')
      allow_any_instance_of(Interactsh::HttpClient).to receive(:make_register_request).and_return(double(code: '200'))
      allow(Xid).to receive_message_chain(:new, :to_s).and_return('correlation-id')
    end

    it 'can generate a domain for interaction testing' do
      # Ensure the new_domain method works with the mocks
      domain = client.new_domain
      expect(domain).to eq('correlation-idrandom-string.oast.me')
    end
  end
end

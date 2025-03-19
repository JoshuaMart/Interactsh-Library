# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Interactsh::Client do
  let(:server) { 'oast.me' }
  let(:token) { 'test-token' }
  let(:client) { Interactsh::Client.new(server, token) }
  let(:http_client) { instance_double(Interactsh::HttpClient) }
  let(:correlation_id) { 'test-correlation-id1' }

  before do
    allow(Interactsh::HttpClient).to receive(:new).with(server, token).and_return(http_client)
    allow(Xid).to receive_message_chain(:new, :to_s).and_return(correlation_id)
    allow(Interactsh::Utils).to receive(:generate_uuid).and_return('test-secret')
    allow(Interactsh::Utils).to receive(:generate_random_string).with(13).and_return('random-string')
  end

  describe '#initialize' do
    it 'sets the server and token' do
      expect(client.server).to eq(server)
      expect(client.token).to eq(token)
    end

    it 'generates random data and secret' do
      expect(client.random_data).to eq('random-string')
      expect(client.secret).to eq('test-secret')
    end

    it 'creates an RSA key pair' do
      expect(client.rsa).to be_a(OpenSSL::PKey::RSA)
    end

    it 'encodes the public key' do
      expect(client.public_key_encoded).to be_a(String)
    end
  end

  describe '#new_domain' do
    before do
      allow(http_client).to receive(:make_register_request).and_return(double('response', code: '200'))
    end

    it 'registers a new correlation ID' do
      expected_data = {
        'public-key': client.public_key_encoded,
        'secret-key': 'test-secret',
        'correlation-id': correlation_id
      }

      expect(http_client).to receive(:make_register_request).with(expected_data)
      client.new_domain
    end

    it 'returns a domain using the correlation ID, random data, and server' do
      domain = client.new_domain
      expect(domain).to eq("#{correlation_id}random-string.#{server}")
    end

    context 'when registration fails' do
      before do
        allow(http_client).to receive(:make_register_request).and_return(double('response', code: '500'))
      end

      it 'raises a RegistrationError' do
        expect { client.new_domain }.to raise_error(Interactsh::RegistrationError)
      end
    end
  end

  describe '#poll' do
    let(:host) { "#{correlation_id}random-string.#{server}" }
    let(:response) { double('response', body: '{"data":[]}', code: '200') }

    before do
      allow(http_client).to receive(:make_poll_request).and_return(response)
      allow(http_client).to receive(:response_successful?).with(response).and_return(true)
    end

    it 'extracts the correlation ID from the host' do
      expect(http_client).to receive(:make_poll_request).with(correlation_id, 'test-secret')
      client.poll(host)
    end

    it 'returns an empty array if no data is found' do
      expect(client.poll(host)).to eq([])
    end

    context 'with interaction data' do
      let(:decrypted_data) { { 'protocol' => 'http', 'remote-address' => '192.168.1.1' } }
      let(:response_body) do
        {
          'aes_key' => 'encrypted-aes-key',
          'data' => %w[encrypted-data-1 encrypted-data-2]
        }.to_json
      end
      let(:response) { double('response', body: response_body, code: '200') }

      before do
        crypto_instance = instance_double(Interactsh::Crypto)
        allow(Interactsh::Crypto).to receive(:new).and_return(crypto_instance)
        allow(crypto_instance).to receive(:decrypt_data)
          .with('encrypted-aes-key', 'encrypted-data-1').and_return(decrypted_data.merge('id' => '1'))
        allow(crypto_instance).to receive(:decrypt_data)
          .with('encrypted-aes-key', 'encrypted-data-2').and_return(decrypted_data.merge('id' => '2'))
      end

      it 'decrypts and returns the interaction data' do
        result = client.poll(host)
        expect(result.size).to eq(2)
        expect(result[0]['protocol']).to eq('http')
        expect(result[0]['id']).to eq('1')
        expect(result[1]['id']).to eq('2')
      end
    end

    context 'when polling fails' do
      before do
        allow(http_client).to receive(:response_successful?).and_raise(Interactsh::PollError.new('Polling failed'))
      end

      it 'propagates the PollError exception' do
        expect { client.poll(host) }.to raise_error(Interactsh::PollError, 'Polling failed')
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Interactsh::HttpClient do
  let(:server) { 'oast.me' }
  let(:token) { 'test-token' }
  let(:http_client) { Interactsh::HttpClient.new(server, token) }

  describe '#make_poll_request' do
    let(:correlation_id) { 'test-correlation-id' }
    let(:secret) { 'test-secret' }
    let(:poll_url) { "https://#{server}/poll?id=#{correlation_id}&secret=#{secret}" }

    context 'when the request is successful' do
      before do
        stub_request(:get, poll_url)
          .with(headers: { 'Authorization' => token })
          .to_return(status: 200, body: '{"data":[]}')
      end

      it 'makes a GET request to the correct URL' do
        http_client.make_poll_request(correlation_id, secret)
        expect(WebMock).to have_requested(:get, poll_url)
          .with(headers: { 'Authorization' => token })
      end

      it 'returns the response' do
        response = http_client.make_poll_request(correlation_id, secret)
        expect(response.code).to eq('200')
      end
    end

    context 'when the request fails' do
      before do
        stub_request(:get, poll_url)
          .to_raise(StandardError.new('Network error'))
      end

      it 'raises an HTTPRequestError' do
        expect { http_client.make_poll_request(correlation_id, secret) }
          .to raise_error(Interactsh::HTTPRequestError)
      end
    end
  end

  describe '#make_register_request' do
    let(:register_url) { "https://#{server}/register" }
    let(:data) do
      {
        'public-key': 'test-public-key',
        'secret-key': 'test-secret',
        'correlation-id': 'test-correlation-id'
      }
    end

    context 'when the request is successful' do
      before do
        stub_request(:post, register_url)
          .with(
            headers: { 'Authorization' => token, 'Content-Type' => 'application/json' },
            body: data.to_json
          )
          .to_return(status: 200, body: '{}')
      end

      it 'makes a POST request to the correct URL with proper headers' do
        http_client.make_register_request(data)
        expect(WebMock).to have_requested(:post, register_url)
          .with(
            headers: { 'Authorization' => token, 'Content-Type' => 'application/json' },
            body: data.to_json
          )
      end

      it 'returns the response' do
        response = http_client.make_register_request(data)
        expect(response.code).to eq('200')
      end
    end

    context 'when the request fails' do
      before do
        stub_request(:post, register_url)
          .to_raise(StandardError.new('Network error'))
      end

      it 'raises an HTTPRequestError' do
        expect { http_client.make_register_request(data) }
          .to raise_error(Interactsh::HTTPRequestError)
      end
    end
  end

  describe '#response_successful?' do
    context 'when response is nil' do
      it 'raises a PollError' do
        expect { http_client.response_successful?(nil) }
          .to raise_error(Interactsh::PollError)
      end
    end

    context 'when response code is not 200' do
      let(:response) { double('response', code: '404') }

      it 'raises a PollError' do
        expect { http_client.response_successful?(response) }
          .to raise_error(Interactsh::PollError)
      end
    end

    context 'when response code is 200' do
      let(:response) { double('response', code: '200') }

      it 'returns true' do
        expect(http_client.response_successful?(response)).to be true
      end
    end
  end
end

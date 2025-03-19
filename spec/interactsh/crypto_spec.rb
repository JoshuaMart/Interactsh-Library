# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Interactsh::Crypto do
  let(:rsa) { OpenSSL::PKey::RSA.new(2048) }
  let(:crypto) { Interactsh::Crypto.new(rsa) }

  describe '#decrypt_data' do
    context 'when decryption is successful' do
      let(:test_data) { { 'protocol' => 'http', 'remote-address' => '192.168.1.1' } }
      let(:aes_key) { 'encrypted_aes_key' }
      let(:encrypted_data) { 'encrypted_data' }

      before do
        # Mock the private decrypt_aes_key method
        allow(crypto).to receive(:decrypt_aes_key).with(aes_key).and_return('decrypted_aes_key')
        # Mock the private decrypt_payload method
        allow(crypto).to receive(:decrypt_payload).with('decrypted_aes_key', encrypted_data).and_return(test_data)
      end

      it 'returns the decrypted data' do
        result = crypto.decrypt_data(aes_key, encrypted_data)
        expect(result).to eq(test_data)
      end
    end

    context 'when decryption fails' do
      let(:aes_key) { 'invalid_aes_key' }
      let(:encrypted_data) { 'invalid_encrypted_data' }

      before do
        allow(crypto).to receive(:decrypt_aes_key).with(aes_key).and_raise(StandardError.new('Decryption failed'))
      end

      it 'raises a DecryptionError' do
        expect { crypto.decrypt_data(aes_key, encrypted_data) }.to raise_error(Interactsh::DecryptionError)
      end

      it 'includes the original error message' do
        crypto.decrypt_data(aes_key, encrypted_data)
      rescue Interactsh::DecryptionError => e
        expect(e.message).to include('Decryption failed')
      end
    end
  end

  # More detailed tests for private methods
  describe '#decrypt_aes_key (private method)' do
    it 'exists as a private method' do
      expect(crypto.private_methods).to include(:decrypt_aes_key)
    end

    # Real integration test for decrypt_aes_key using send to call the private method
    it 'decrypts an AES key using RSA' do
      # Key generation and encryption for testing
      test_key = SecureRandom.hex(16)
      encrypted_key = JOSE::JWA::PKCS1.rsaes_oaep_encrypt(
        OpenSSL::Digest::SHA256,
        test_key,
        rsa.public_key
      )
      encoded_key = Base64.urlsafe_encode64(encrypted_key)

      # Check that the method can decrypt correctly
      decrypted_key = crypto.send(:decrypt_aes_key, encoded_key)
      expect(decrypted_key).to eq(test_key)
    end

    it 'handles decryption with proper Base64 decoding' do
      # This part checks that the method uses Base64.urlsafe_decode64
      expect(Base64).to receive(:urlsafe_decode64).with('some_key').and_return('decoded_key')
      expect(JOSE::JWA::PKCS1).to receive(:rsaes_oaep_decrypt)
        .with(OpenSSL::Digest::SHA256, 'decoded_key', an_instance_of(OpenSSL::PKey::RSA))
        .and_return('result')

      result = crypto.send(:decrypt_aes_key, 'some_key')
      expect(result).to eq('result')
    end
  end

  describe '#decrypt_payload (private method)' do
    it 'exists as a private method' do
      expect(crypto.private_methods).to include(:decrypt_payload)
    end

    it 'decrypts a payload using AES-256-CFB' do
      # Data preparation
      decrypted_aes_key = 'test_key_for_aes_256'
      json_data = '{"protocol":"http","data":"test"}'

      # Simulation of Base64.decode64 behavior
      allow(Base64).to receive(:decode64).with('encrypted_payload').and_return('secretdata')

      # Simulation of decryption behavior
      decipher = instance_double(OpenSSL::Cipher)
      allow(OpenSSL::Cipher).to receive(:new).with('aes-256-cfb').and_return(decipher)
      allow(decipher).to receive(:decrypt)
      allow(decipher).to receive(:key=).with(decrypted_aes_key)

      # Simulate decryption result with IV (first 16 bytes)
      # followed by the real JSON
      iv = '0123456789012345' # 16 bytes of dummy IVs
      decrypted_with_iv = iv + json_data
      allow(decipher).to receive(:update).with('secretdata').and_return(decrypted_with_iv)
      allow(decipher).to receive(:final).and_return('')

      parsed_json = { 'protocol' => 'http', 'data' => 'test' }
      allow(JSON).to receive(:parse).with(json_data).and_return(parsed_json)

      result = crypto.send(:decrypt_payload, decrypted_aes_key, 'encrypted_payload')
      expect(result).to eq(parsed_json)

      expect(JSON).to have_received(:parse).with(json_data)
    end
  end
end

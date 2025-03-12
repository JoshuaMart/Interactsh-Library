# frozen_string_literal: true

module Interactsh
  # Cryptographic operations for Interactsh
  class Crypto
    def initialize(rsa)
      @rsa = rsa
    end

    # Decrypts interaction data using the provided AES key
    #
    # @param aes_key [String] The encrypted AES key
    # @param enc_data [String] The encrypted data
    # @return [Hash] The decrypted interaction data
    def decrypt_data(aes_key, enc_data)
      decrypted_aes_key = decrypt_aes_key(aes_key)
      decrypt_payload(decrypted_aes_key, enc_data)
    rescue StandardError => e
      puts "[!] Interactsh - Error decrypting data: #{e.message}"
      {}
    end

    private

    # Decrypts the AES key using RSA
    #
    # @param aes_key [String] The encrypted AES key
    # @return [String] The decrypted AES key
    def decrypt_aes_key(aes_key)
      pkey = OpenSSL::PKey::RSA.new(@rsa)
      encrypted_aes_key = Base64.urlsafe_decode64(aes_key)
      JOSE::JWA::PKCS1.rsaes_oaep_decrypt(
        OpenSSL::Digest::SHA256,
        encrypted_aes_key,
        pkey
      )
    end

    # Decrypts the payload using the decrypted AES key
    #
    # @param decrypted_aes_key [String] The decrypted AES key
    # @param enc_data [String] The encrypted data
    # @return [Hash] The decrypted payload as a hash
    def decrypt_payload(decrypted_aes_key, enc_data)
      secretdata = Base64.decode64(enc_data)
      decipher = OpenSSL::Cipher.new('aes-256-cfb')
      decipher.decrypt
      decipher.key = decrypted_aes_key

      # The data minus the size of the IV (first 16 bytes)
      JSON.parse((decipher.update(secretdata) + decipher.final)[16..])
    end
  end
end

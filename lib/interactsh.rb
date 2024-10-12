# frozen_string_literal: true

require 'openssl'
require 'stringio'
require 'jose'
require 'securerandom'
require 'base64'
require 'json'
require 'ruby_xid'
require 'typhoeus'

# InteractSH Ruby Library
class Interactsh
  attr_reader :public_key_encoded, :secret, :server, :random_data, :rsa, :token

  def initialize(server = 'oast.me', token = nil)
    @rsa = OpenSSL::PKey::RSA.new(2048)
    @public_key = @rsa.public_key.to_pem
    @public_key_encoded = Base64.encode64(@public_key)

    @secret = SecureRandom.uuid
    @random_data = Array.new(13) { (Array('a'..'z') + Array(0..9)).sample }.join

    @server = server
    @token = token
  end

  def new_domain
    correlation_id = Xid.new.to_s
    register(correlation_id)

    "#{correlation_id}#{random_data}.#{server}"
  end

  def poll(host)
    correlation_id = host[0..19]
    headers = {}
    headers['Authorization'] = token if token

    response = Typhoeus.get(File.join(server, "/poll?id=#{correlation_id}&secret=#{secret}"), headers: headers)
    unless response&.code == 200
      puts '[!] Interactsh - Problem with data recovery'
      return
    end

    datas = JSON.parse(response.body)
    parse_poll_datas(datas)
  end

  private

  def parse_poll_datas(datas)
    decoded_datas = []

    unless datas.empty?
      datas['data'].each do |enc_data|
        decoded_datas << decrypt_data(datas['aes_key'], enc_data)
      end
    end

    decoded_datas
  end

  def register(correlation_id)
    data = { "public-key": public_key_encoded, "secret-key": secret, "correlation-id": correlation_id }.to_json

    headers = { 'Content-Type' => 'application/json' }
    headers['Authorization'] = token if token

    response = Typhoeus.post(File.join(server, '/register'), body: data, headers: headers)
    return if response.code == 200

    puts '[!] Interactsh - Problem with domain registration'
  end

  def decrypt_data(aes_key, enc_data)
    pkey = OpenSSL::PKey::RSA.new(rsa)
    encrypted_aes_key = Base64.urlsafe_decode64(aes_key)
    decrypted_aes_key = JOSE::JWA::PKCS1.rsaes_oaep_decrypt(OpenSSL::Digest::SHA256, encrypted_aes_key, pkey)

    secretdata = Base64.decode64(enc_data)
    decipher = OpenSSL::Cipher.new('aes-256-cfb')
    decipher.decrypt
    decipher.key = decrypted_aes_key

    # The data minus the size of the IV
    JSON.parse((decipher.update(secretdata) + decipher.final)[16..])
  end
end

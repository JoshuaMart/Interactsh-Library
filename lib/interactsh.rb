# frozen_string_literal: true

require 'openssl'
require 'jose'
require 'stringio'
require 'base64'
require 'json'
require 'ruby_xid'
require 'net/http'
require 'uri'

# InteractSH Ruby Library for Out-of-band Application Security Testing
# This class provides functionality to interact with Interactsh servers
# for security testing and capturing out-of-band interactions.
class Interactsh
  attr_reader :public_key_encoded, :secret, :server, :random_data, :rsa, :token

  # Creates a new Interactsh client
  #
  # @param server [String] The Interactsh server to use (default: 'oast.me')
  # @param token [String, nil] Optional authentication token
  def initialize(server = 'oast.me', token = nil)
    @rsa = OpenSSL::PKey::RSA.new(2048)
    @public_key = @rsa.public_key.to_pem
    @public_key_encoded = Base64.strict_encode64(@public_key)

    @secret = generate_uuid
    @random_data = generate_random_string(13)

    @server = server
    @token = token
  end

  # Generates a new domain for interaction testing
  #
  # @return [String] The generated domain name for interaction testing
  def new_domain
    correlation_id = Xid.new.to_s
    register(correlation_id)

    "#{correlation_id}#{random_data}.#{server}"
  end

  # Polls the server for interaction data for a given host
  #
  # @param host [String] The host to poll data for
  # @return [Array] Array of interaction data or empty array if polling failed
  def poll(host)
    correlation_id = host[0..19]
    headers = {}
    headers['Authorization'] = token if token

    uri = URI.parse("https://#{server}/poll?id=#{correlation_id}&secret=#{secret}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Get.new(uri.request_uri)
    headers.each { |key, value| request[key] = value }

    response = http.request(request)

    unless response&.code.to_i == 200
      puts '[!] Interactsh - Problem with data recovery'
      return []
    end

    data = JSON.parse(response.body)
    parse_poll_data(data)
  end

  private

  # Generates a random string of specified length
  #
  # @param length [Integer] Length of the random string
  # @return [String] Random alphanumeric string
  def generate_random_string(length)
    charset = Array('a'..'z') + Array(0..9)
    Array.new(length) { charset.sample }.join
  end

  # Generates a RFC4122 version 4 UUID
  #
  # @return [String] The generated UUID
  def generate_uuid
    # Generate 16 random bytes
    random_bytes = Array.new(16) { rand(0..255) }

    # Set version (4) and variant (RFC4122)
    random_bytes[6] = (random_bytes[6] & 0x0F) | 0x40 # version 4
    random_bytes[8] = (random_bytes[8] & 0x3F) | 0x80 # variant RFC4122

    # Format as UUID string
    hex = random_bytes.map { |b| b.to_s(16).rjust(2, '0') }.join

    # Insert hyphens according to UUID format
    [hex[0..7], hex[8..11], hex[12..15], hex[16..19], hex[20..31]].join('-')
  end

  # Parses and decrypts poll data
  #
  # @param data [Hash] The poll data to parse
  # @return [Array] The decoded interaction data
  def parse_poll_data(data)
    decoded_data = []

    return decoded_data if data.empty? || !data['data'] || data['data'].empty?

    data['data'].each do |enc_data|
      decoded_data << decrypt_data(data['aes_key'], enc_data)
    end

    decoded_data
  end

  # Registers a correlation ID with the Interactsh server
  #
  # @param correlation_id [String] The correlation ID to register
  # @return [void]
  def register(correlation_id)
    data = {
      'public-key': public_key_encoded,
      'secret-key': secret,
      'correlation-id': correlation_id
    }.to_json

    headers = { 'Content-Type' => 'application/json' }
    headers['Authorization'] = token if token

    uri = URI.parse("https://#{server}/register")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Post.new(uri.request_uri)
    headers.each { |key, value| request[key] = value }
    request.body = data

    response = http.request(request)

    return if response.code.to_i == 200

    puts '[!] Interactsh - Problem with domain registration'
  end

  # Decrypts interaction data using the provided AES key
  #
  # @param aes_key [String] The encrypted AES key
  # @param enc_data [String] The encrypted data
  # @return [Hash] The decrypted interaction data
  def decrypt_data(aes_key, enc_data)
    pkey = OpenSSL::PKey::RSA.new(rsa)
    encrypted_aes_key = Base64.urlsafe_decode64(aes_key)
    decrypted_aes_key = JOSE::JWA::PKCS1.rsaes_oaep_decrypt(
      OpenSSL::Digest::SHA256,
      encrypted_aes_key,
      pkey
    )

    secretdata = Base64.decode64(enc_data)
    decipher = OpenSSL::Cipher.new('aes-256-cfb')
    decipher.decrypt
    decipher.key = decrypted_aes_key

    # The data minus the size of the IV (first 16 bytes)
    JSON.parse((decipher.update(secretdata) + decipher.final)[16..])
  rescue StandardError => e
    puts "[!] Interactsh - Error decrypting data: #{e.message}"
    {}
  end
end

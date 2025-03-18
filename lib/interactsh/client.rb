# frozen_string_literal: true

module Interactsh
  # Main client class for Interactsh interaction
  class Client
    attr_reader :public_key_encoded, :secret, :server, :random_data, :rsa, :token

    # Creates a new Interactsh client
    #
    # @param server [String] The Interactsh server to use (default: 'oast.me')
    # @param token [String, nil] Optional authentication token
    def initialize(server = 'oast.me', token = nil)
      @rsa = OpenSSL::PKey::RSA.new(2048)
      @public_key = @rsa.public_key.to_pem
      @public_key_encoded = Base64.strict_encode64(@public_key)

      @secret = Utils.generate_uuid
      @random_data = Utils.generate_random_string(13)

      @server = server
      @token = token
      @http_client = HttpClient.new(server, token)
      @crypto = Crypto.new(@rsa)
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
      response = @http_client.make_poll_request(correlation_id, secret)

      return [] unless @http_client.response_successful?(response)

      data = JSON.parse(response.body)
      parse_poll_data(data)
    end

    private

    # Parses and decrypts poll data
    #
    # @param data [Hash] The poll data to parse
    # @return [Array] The decoded interaction data
    def parse_poll_data(data)
      decoded_data = []

      return decoded_data if data.empty? || !data['data'] || data['data'].empty?

      data['data'].each do |enc_data|
        decoded_data << @crypto.decrypt_data(data['aes_key'], enc_data)
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
      }

      response = @http_client.make_register_request(data)
      return if response && response.code.to_i == 200

      raise RegistrationError, "Problem with domain registration. Response code: #{response&.code}"
    end
  end
end

# frozen_string_literal: true

module Interactsh
  # HTTP client for Interactsh API
  class HttpClient
    def initialize(server, token)
      @server = server
      @token = token
    end

    # Makes the HTTP request to poll for interaction data
    #
    # @param correlation_id [String] The correlation ID to poll for
    # @param secret [String] The secret key
    # @return [Net::HTTPResponse] The HTTP response
    def make_poll_request(correlation_id, secret)
      uri = URI.parse("https://#{@server}/poll?id=#{correlation_id}&secret=#{secret}")
      http = setup_http_client(uri)

      request = Net::HTTP::Get.new(uri.request_uri)
      apply_headers(request)

      http.request(request)
    rescue StandardError => e
      raise HTTPRequestError, "HTTP request error: #{e.message}"
    end

    # Makes the HTTP request to register a correlation ID
    #
    # @param data [Hash] The data to send
    # @return [Net::HTTPResponse] The HTTP response
    def make_register_request(data)
      uri = URI.parse("https://#{@server}/register")
      http = setup_http_client(uri)

      request = Net::HTTP::Post.new(uri.request_uri)
      apply_headers(request, 'Content-Type' => 'application/json')
      request.body = data.to_json

      http.request(request)
    rescue StandardError => e
      raise HTTPRequestError, "HTTP request error: #{e.message}"
    end

    # Checks if the HTTP response was successful
    #
    # @param response [Net::HTTPResponse, nil] The HTTP response
    # @return [Boolean] True if response is successful, false otherwise
    def response_successful?(response)
      if !response || response.code.to_i != 200
        raise PollError, "Problem with data recovery. Response code: #{response&.code}"
      end

      true
    end

    private

    # Sets up an HTTP client
    #
    # @param uri [URI] The URI to connect to
    # @return [Net::HTTP] The configured HTTP client
    def setup_http_client(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.verify_hostname = false
      http
    end

    # Applies headers to an HTTP request
    #
    # @param request [Net::HTTPRequest] The request to apply headers to
    # @param additional_headers [Hash] Additional headers to apply
    # @return [void]
    def apply_headers(request, additional_headers = {})
      headers = additional_headers.dup
      headers['Authorization'] = @token if @token

      headers.each { |key, value| request[key] = value }
    end
  end
end

# frozen_string_literal: true

module Interactsh
  # Utility methods for Interactsh
  module Utils
    module_function

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
      random_bytes = create_uuid_bytes
      hex = random_bytes.map { |b| b.to_s(16).rjust(2, '0') }.join
      format_uuid(hex)
    end

    # Creates the byte array for UUID with proper version and variant
    #
    # @return [Array] Array of bytes for UUID
    def create_uuid_bytes
      bytes = Array.new(16) { rand(0..255) }
      # Set version (4) and variant (RFC4122)
      bytes[6] = (bytes[6] & 0x0F) | 0x40 # version 4
      bytes[8] = (bytes[8] & 0x3F) | 0x80 # variant RFC4122
      bytes
    end

    # Formats a hex string as a UUID with hyphens
    #
    # @param hex [String] The hex string to format
    # @return [String] The formatted UUID string
    def format_uuid(hex)
      [hex[0..7], hex[8..11], hex[12..15], hex[16..19], hex[20..31]].join('-')
    end
  end
end

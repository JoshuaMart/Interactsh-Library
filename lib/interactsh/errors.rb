# frozen_string_literal: true

module Interactsh
  # Custom exceptions for Interactsh
  class Error < StandardError; end
  class RegistrationError < Error; end
  class PollError < Error; end
  class DecryptionError < Error; end
  class HTTPRequestError < Error; end
end

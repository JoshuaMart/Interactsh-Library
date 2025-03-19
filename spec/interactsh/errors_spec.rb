# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Interactsh Errors' do
  describe Interactsh::Error do
    it 'is a subclass of StandardError' do
      expect(Interactsh::Error.superclass).to eq(StandardError)
    end
  end

  describe Interactsh::RegistrationError do
    it 'is a subclass of Interactsh::Error' do
      expect(Interactsh::RegistrationError.superclass).to eq(Interactsh::Error)
    end

    it 'can be instantiated with a message' do
      error = Interactsh::RegistrationError.new('Registration failed')
      expect(error.message).to eq('Registration failed')
    end
  end

  describe Interactsh::PollError do
    it 'is a subclass of Interactsh::Error' do
      expect(Interactsh::PollError.superclass).to eq(Interactsh::Error)
    end

    it 'can be instantiated with a message' do
      error = Interactsh::PollError.new('Polling failed')
      expect(error.message).to eq('Polling failed')
    end
  end

  describe Interactsh::DecryptionError do
    it 'is a subclass of Interactsh::Error' do
      expect(Interactsh::DecryptionError.superclass).to eq(Interactsh::Error)
    end

    it 'can be instantiated with a message' do
      error = Interactsh::DecryptionError.new('Decryption failed')
      expect(error.message).to eq('Decryption failed')
    end
  end

  describe Interactsh::HTTPRequestError do
    it 'is a subclass of Interactsh::Error' do
      expect(Interactsh::HTTPRequestError.superclass).to eq(Interactsh::Error)
    end

    it 'can be instantiated with a message' do
      error = Interactsh::HTTPRequestError.new('HTTP request failed')
      expect(error.message).to eq('HTTP request failed')
    end
  end
end

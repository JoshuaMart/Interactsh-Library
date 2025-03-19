# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Interactsh::Utils do
  describe '.generate_random_string' do
    it 'generates a string of the specified length' do
      length = 10
      random_string = Interactsh::Utils.generate_random_string(length)
      expect(random_string.length).to eq(length)
    end

    it 'generates alphanumeric characters only' do
      random_string = Interactsh::Utils.generate_random_string(20)
      expect(random_string).to match(/^[a-z0-9]+$/)
    end

    it 'generates different strings on successive calls' do
      first_string = Interactsh::Utils.generate_random_string(15)
      second_string = Interactsh::Utils.generate_random_string(15)
      expect(first_string).not_to eq(second_string)
    end
  end

  describe '.generate_uuid' do
    it 'generates a valid RFC4122 UUID format' do
      uuid = Interactsh::Utils.generate_uuid
      expect(uuid).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
    end

    it 'generates version 4 UUIDs' do
      uuid = Interactsh::Utils.generate_uuid
      version_bits = uuid[14, 1]
      expect(version_bits).to eq('4')
    end

    it 'generates variant 1 UUIDs (RFC4122)' do
      uuid = Interactsh::Utils.generate_uuid
      variant_bits = uuid[19, 1]
      expect(%w[8 9 a b]).to include(variant_bits)
    end
  end

  describe '.create_uuid_bytes' do
    it 'returns an array of 16 bytes' do
      bytes = Interactsh::Utils.create_uuid_bytes
      expect(bytes).to be_an(Array)
      expect(bytes.size).to eq(16)
      expect(bytes.all? { |b| b.is_a?(Integer) && b.between?(0, 255) }).to be(true)
    end

    it 'sets the version bits correctly' do
      bytes = Interactsh::Utils.create_uuid_bytes
      # Check if 6th byte has version 4 (0100xxxx)
      expect(bytes[6] & 0xF0).to eq(0x40)
    end

    it 'sets the variant bits correctly' do
      bytes = Interactsh::Utils.create_uuid_bytes
      # Check if 8th byte has variant RFC4122 (10xxxxxx)
      expect(bytes[8] & 0xC0).to eq(0x80)
    end
  end

  describe '.format_uuid' do
    it 'formats a hexadecimal string into UUID format with hyphens' do
      hex = '123e4567e89b12d3a456426614174000'
      uuid = Interactsh::Utils.format_uuid(hex)
      expect(uuid).to eq('123e4567-e89b-12d3-a456-426614174000')
    end
  end
end

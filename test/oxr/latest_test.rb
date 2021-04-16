# frozen_string_literal: true

require 'test_helper'

module OXR
  class LatestTest < Minitest::Test
    def setup
      OXR.configure { |config| config.app_id = 'XXX' }
      @endpoint = 'https://openexchangerates.org/api/latest.json'
    end

    def test_latest
      response = File.expand_path '../fixtures/latest.json', __dir__
      stub_request(:get, @endpoint)
        .with(query: { 'app_id' => 'XXX' })
        .to_return status: 200, body: File.open(response)

      data = OXR.latest
      refute_nil data['timestamp']
      assert_equal 'USD', data['base']
      assert_equal 1, data.dig('rates', 'USD')
      assert_in_delta 0.890663, data.dig('rates', 'EUR')
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def test_latest_with_alternate_base_currency
      OXR.configure { |config| config.base = 'EUR' }
      response = File.expand_path '../fixtures/latest_custom_base.json', __dir__
      stub_request(:get, @endpoint)
        .with(query: { 'app_id' => 'XXX', 'base' => 'EUR' })
        .to_return status: 200, body: File.open(response)

      data = OXR.latest
      assert_equal 'EUR', data['base']
      assert_equal 1, data.dig('rates', 'EUR')
      assert_in_delta 1.17887, data.dig('rates', 'USD')
    ensure
      OXR.configure { |config| config.base = nil }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def test_latest_with_custom_source
      OXR.configure do |config|
        config.latest = File.expand_path '../fixtures/fantasy.json', __dir__
      end

      data = OXR.latest
      assert_equal 42, data.dig('rates', 'GBP')
    ensure
      OXR.reset_sources
    end
  end
end

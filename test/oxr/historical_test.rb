# frozen_string_literal: true

require 'test_helper'

module OXR
  class HistoricalTest < Minitest::Test
    def setup
      OXR.configure { |config| config.app_id = 'XXX' }
      @endpoint = 'https://openexchangerates.org/api/historical/2015-06-14.json'
    end

    def test_historical
      response = File.expand_path '../fixtures/historical.json', __dir__
      stub_request(:get, @endpoint)
        .with(query: { 'app_id' => 'XXX' })
        .to_return status: 200, body: File.open(response)

      data = OXR.historical on: Date.new(2015, 6, 14)
      refute_nil data['timestamp']
      assert_equal 'USD', data['base']
      assert_equal 1, data.dig('rates', 'USD')
      assert_in_delta 0.642607, data.dig('rates', 'GBP')
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    def test_historical_with_alternate_base_currency
      OXR.configure { |config| config.base = 'EUR' }
      response = File.expand_path '../fixtures/historical_custom_base.json', __dir__
      stub_request(:get, @endpoint)
        .with(query: { 'app_id' => 'XXX', 'base' => 'EUR' })
        .to_return status: 200, body: File.open(response)

      data = OXR.historical on: Date.new(2015, 6, 14)
      refute_nil data['timestamp']
      assert_equal 'EUR', data['base']
      assert_equal 1, data.dig('rates', 'EUR')
      assert_in_delta 0.881934, data.dig('rates', 'GBP')
    ensure
      OXR.configure { |config| config.base = nil }
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def test_historical_with_custom_source
      OXR.configure do |config|
        config.historical = File.expand_path '../fixtures/fantasy.json', __dir__
      end

      data = OXR.historical on: Date.new(2015, 6, 14)
      assert_equal 42, data.dig('rates', 'GBP')
    ensure
      OXR.reset_sources
    end
  end
end

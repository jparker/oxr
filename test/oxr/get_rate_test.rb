# frozen_string_literal: true

require 'test_helper'

module OXR
  class GetRateTest < Minitest::Test
    def setup
      stub_request(:get, %r{\Ahttps://openexchangerates.org/.*}).to_return do |req|
        endpoint = req.uri.path[%r{\A/api/(.+?)\b}, 1]
        { status: 200, body: File.open("test/fixtures/#{endpoint}.json") }
      end
      OXR.configure { |config| config.app_id = 'XXX' }
    end

    def test_get_rate
      assert_equal 1, OXR.get_rate('USD')
      assert_in_delta 0.703087, OXR.get_rate('GBP')
      assert_in_delta 111.7062, OXR.get_rate('JPY')
    end

    def test_get_rate_alias
      assert_equal 1, OXR['USD']
      assert_in_delta 0.703087, OXR['GBP']
      assert_in_delta 111.7062, OXR['JPY']
    end

    def test_get_rate_accepts_symbols
      assert_equal 1, OXR[:USD]
    end

    def test_get_rate_with_invalid_currency_returns_nil
      assert_nil OXR['bogus']
    end

    def test_get_rate_with_on_keyword
      assert_equal 1, OXR.get_rate('USD', on: Date.new(2015, 6, 14))
      assert_in_delta 0.642607, OXR.get_rate('GBP', on: Date.new(2015, 6, 14))
    end
  end
end

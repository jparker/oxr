# frozen_string_literal: true

require 'test_helper'

module OXR
  class CurrenciesTest < Minitest::Test
    def setup
      OXR.configure { |config| config.app_id = 'XXX' }
      @endpoint = 'https://openexchangerates.org/api/currencies.json'
    end

    def test_currencies
      response = File.expand_path '../fixtures/currencies.json', __dir__
      stub_request(:get, @endpoint)
        .with(query: { 'app_id' => 'XXX' })
        .to_return status: 200, body: File.open(response)

      data = OXR.currencies
      assert_equal 'British Pound Sterling', data['GBP']
      assert_equal 'United States Dollar', data['USD']
    end
  end
end

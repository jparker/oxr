# frozen_string_literal: true

require 'test_helper'

module OXR
  class UsageTest < Minitest::Test
    def setup
      OXR.configure { |config| config.app_id = 'XXX' }
      @endpoint = 'https://openexchangerates.org/api/usage.json'
    end

    def test_usage
      response = File.expand_path '../fixtures/usage.json', __dir__
      stub_request(:get, @endpoint)
        .with(query: { 'app_id' => 'XXX' })
        .to_return status: 200, body: File.open(response)

      data = OXR.usage
      refute_nil data.dig('data', 'usage', 'requests')
      refute_nil data.dig('data', 'usage', 'requests_quota')
      refute_nil data.dig('data', 'usage', 'requests_remaining')
    end
  end
end

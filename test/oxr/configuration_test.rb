# frozen_string_literal: true

require 'test_helper'

module OXR
  class ConfigurationTest < Minitest::Test
    def setup
      @path = File.expand_path '../fixtures/fantasy.json', __dir__
    end

    def teardown
      OXR.configure(&:reset_sources)
    end

    def test_set_latest_endpoint_to_string_formatted_as_path
      OXR.configure { |config| config.latest = @path }
      assert_equal 42, OXR['GBP']
    end

    def test_set_latest_endpoint_to_string_formatted_as_local_uri
      OXR.configure { |config| config.latest = "file://#{@path}" }
      assert_equal 42, OXR['GBP']
    end

    def test_set_latest_endpoint_to_string_formatted_as_remote_uri
      OXR.configure { |config| config.latest = 'https://example.com/api/latest.json' }
      stub_request(:get, 'https://example.com/api/latest.json')
        .to_return status: 200, body: File.open(@path)

      assert_equal 42, OXR['GBP']
    end

    def test_set_latest_endpoint_to_uri
      OXR.configure { |config| config.latest = URI.parse 'https://example.com/api/latest.json' }
      stub_request(:get, 'https://example.com/api/latest.json')
        .to_return status: 200, body: File.open(@path)

      assert_equal 42, OXR['GBP']
    end

    def test_set_latest_endpoint_to_uri_representation_of_local_file
      OXR.configure { |config| config.latest = URI.parse "file://#{@path}" }
      assert_equal 42, OXR['GBP']
    end

    def test_set_latest_endpoint_to_pathname
      OXR.configure { |config| config.latest = Pathname.new @path }
      assert_equal 42, OXR['GBP']
    end
  end
end

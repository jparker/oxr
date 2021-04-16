# frozen_string_literal: true

require 'test_helper'

class OXRTest < Minitest::Test
  # rubocop:disable Metrics/AbcSize
  def test_missing_app_id
    OXR.configure { |config| config.app_id = nil }
    response = File.expand_path './fixtures/missing_app_id.json', __dir__
    stub_request(:get, %r{\Ahttps://openexchangerates.org/api/.*})
      .with(query: { 'app_id' => '' })
      .to_return status: 401, body: File.open(response)

    error = assert_raises(OXR::ApiError) { OXR['USD'] }
    assert_match(/No App ID provided/, error.description)
    assert_equal 'missing_app_id', error.response['message']
    assert_equal 401, error.response['status']
  end
  # rubocop:enable Metrics/AbcSize

  def test_invalid_app_id
    response = File.expand_path './fixtures/invalid_app_id.json', __dir__
    stub_request(:get, %r{\Ahttps://openexchangerates.org/api/.*})
      .to_return status: 401, body: File.open(response)

    error = assert_raises(OXR::ApiError) { OXR['USD'] }
    assert_match(/Invalid App ID/, error.description)
    assert_equal 'invalid_app_id', error.response['message']
    assert_equal 401, error.response['status']
  end

  def test_access_restricted
    response = File.expand_path './fixtures/access_restricted.json', __dir__
    stub_request(:get, %r{\Ahttps://openexchangerates.org/api/.*})
      .to_return status: 429, body: File.open(response)

    error = assert_raises(OXR::ApiError) { OXR['USD'] }
    assert_match(/Access restricted/, error.description)
    assert_equal 'access_restricted', error.response['message']
    assert_equal 429, error.response['status']
  end

  # rubocop:disable Metrics/AbcSize
  def test_invalid_base
    OXR.configure { |config| config.base = 'XXX' }
    response = File.expand_path './fixtures/invalid_base.json', __dir__
    stub_request(:get, %r{\Ahttps://openexchangerates.org/api/.*})
      .to_return status: 400, body: File.open(response)

    error = assert_raises(OXR::ApiError) { OXR['USD'] }
    assert_match(/Invalid `base` currency \[XXX\]/, error.description)
    assert_equal 'invalid_base', error.response['message']
    assert_equal 400, error.response['status']
  ensure
    OXR.configure { |config| config.base = nil }
  end
  # rubocop:enable Metrics/AbcSize
end

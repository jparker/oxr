require 'test_helper'

class OXRTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OXR::VERSION
  end

  def test_latest
    stub_request(:get, "#{OXR::BASE_PATH}latest.json?app_id=XXX")
      .to_return status: 200, body: File.open('test/fixtures/latest.json')
    response = OXR.new('XXX').latest

    refute_nil response['timestamp']
    assert_equal 'USD', response['base']
    assert_equal 1, response['rates']['USD']
    refute_nil response['rates']['GBP']
  end

  def test_historical
    stub_request(:get, "#{OXR::BASE_PATH}historical/2015-06-14.json?app_id=XXX")
      .to_return status: 200, body: File.open('test/fixtures/historical.json')
    response = OXR.new('XXX').historical on: Date.new(2015, 6, 14)

    refute_nil response['timestamp']
    assert_equal 'USD', response['base']
    assert_equal 1, response['rates']['USD']
    refute_nil response['rates']['GBP']
  end

  def test_currencies
    stub_request(:get, "#{OXR::BASE_PATH}currencies.json?app_id=XXX")
      .to_return status: 200, body: File.open('test/fixtures/currencies.json')
    response = OXR.new('XXX').currencies

    assert_equal 'British Pound Sterling', response['GBP']
    assert_equal 'United States Dollar', response['USD']
  end

  def test_usage
    stub_request(:get, "#{OXR::BASE_PATH}usage.json?app_id=XXX")
      .to_return status: 200, body: File.open('test/fixtures/usage.json')
    response = OXR.new('XXX').usage

    refute_nil response['data']['usage']['requests']
    refute_nil response['data']['usage']['requests_quota']
    refute_nil response['data']['usage']['requests_remaining']
  end

  def test_missing_app_id
    stub_request(:get, "#{OXR::BASE_PATH}latest.json?app_id=")
      .to_return status: 401, body: File.open('test/fixtures/missing_app_id.json')

    error = assert_raises(OXR::OXRError) { OXR.new(nil).latest }
    assert_match /No App ID provided/, error.message
    assert_equal 'missing_app_id', error.response['message']
    assert_equal 401, error.response['status']
  end

  def test_invalid_app_id
    stub_request(:get, "#{OXR::BASE_PATH}latest.json?app_id=XXX")
      .to_return status: 401, body: File.open('test/fixtures/invalid_app_id.json')

    error = assert_raises(OXR::OXRError) { OXR.new('XXX').latest }
    assert_match /Invalid App ID/, error.message
    assert_equal 'invalid_app_id', error.response['message']
    assert_equal 401, error.response['status']
  end

  def test_access_restricted
    stub_request(:get, "#{OXR::BASE_PATH}latest.json?app_id=XXX")
      .to_return status: 429, body: File.open('test/fixtures/access_restricted.json')

    error = assert_raises(OXR::OXRError) { OXR.new('XXX').latest }
    assert_match /Access restricted/, error.message
    assert_equal 'access_restricted', error.response['message']
    assert_equal 429, error.response['status']
  end
end

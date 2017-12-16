require 'test_helper'

class OXRTest < Minitest::Test
  def setup
    OXR.configure do |config|
      config.app_id = 'XXX'
    end
  end

  def teardown
    OXR.reset_sources
    OXR.configure do |config|
      config.base = nil
    end
  end

  def test_get_rate
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX')
      .to_return status: 200, body: File.open(fixture('latest.json'))
    assert_equal 1, OXR.get_rate('USD')
    assert_in_delta 0.703087, OXR.get_rate('GBP')
    assert_in_delta 111.7062, OXR.get_rate('JPY')
  end

  def test_get_rate_with_date
    stub_request(:get, 'https://openexchangerates.org/api/historical/2015-06-14.json?app_id=XXX')
      .to_return status: 200, body: File.open(fixture('historical.json'))
    assert_equal 1, OXR.get_rate('USD', on: Date.new(2015, 6, 14))
    assert_in_delta 0.642607, OXR.get_rate('GBP', on: Date.new(2015, 6, 14))
  end

  def test_get_rate_alias
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX')
      .to_return status: 200, body: File.open(fixture('latest.json'))
    assert_equal 1, OXR['USD']
    assert_in_delta 0.703087, OXR['GBP']
    assert_in_delta 111.7062, OXR['JPY']
  end

  def test_get_rate_with_currency_as_symbol
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX')
      .to_return status: 200, body: File.open(fixture('latest.json'))
    assert_equal 1, OXR[:USD]
  end

  def test_get_rate_with_invalid_currency
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX')
      .to_return status: 200, body: File.open(fixture('latest.json'))
    assert_nil OXR['bogus']
  end

  def test_latest
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX')
      .to_return status: 200, body: File.open(fixture('latest.json'))
    response = OXR.latest
    refute_nil response['timestamp']
    assert_equal 'USD', response['base']
    assert_equal 1, response['rates']['USD']
  end

  def test_latest_with_custom_source
    OXR.configure do |config|
      config.latest = fixture 'fantasy.json'
    end
    response = OXR.latest
    assert_equal 42, response['rates']['GBP']
  end

  def test_latest_with_base
    OXR.configure do |config|
      config.base = 'EUR'
    end
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX&base=EUR')
      .to_return status: 200, body: File.open(fixture('latest_custom_base.json'))
    response = OXR.latest
    refute_nil response['timestamp']
    assert_equal 'EUR', response['base']
    assert_equal 1, response['rates']['EUR']
  end

  def test_historical
    stub_request(:get, 'https://openexchangerates.org/api/historical/2015-06-14.json?app_id=XXX')
      .to_return status: 200, body: File.open(fixture('historical.json'))
    response = OXR.historical on: Date.new(2015, 6, 14)
    refute_nil response['timestamp']
    assert_equal 'USD', response['base']
    assert_equal 1, response['rates']['USD']
    assert_in_delta 0.642607, response['rates']['GBP']
  end

  def test_historical_with_custom_source
    OXR.configure do |config|
      config.historical = fixture 'fantasy.json'
    end
    response = OXR.historical on: Date.new(2015, 6, 14)
    assert_equal 42, response['rates']['GBP']
  end

  def test_historical_with_base
    OXR.configure do |config|
      config.base = 'EUR'
    end
    stub_request(:get, 'https://openexchangerates.org/api/historical/2017-12-05.json?app_id=XXX&base=EUR')
      .to_return status: 200, body: File.open(fixture('historical_custom_base.json'))
    response = OXR.historical on: Date.new(2017, 12, 5)
    refute_nil response['timestamp']
    assert_equal 'EUR', response['base']
    assert_equal 1, response['rates']['EUR']
    assert_in_delta 0.881934, response['rates']['GBP']
  end

  def test_currencies
    stub_request(:get, 'https://openexchangerates.org/api/currencies.json?app_id=XXX')
      .to_return status: 200, body: File.open(fixture('currencies.json'))
    response = OXR.currencies
    assert_equal 'British Pound Sterling', response['GBP']
    assert_equal 'United States Dollar', response['USD']
  end

  def test_usage
    stub_request(:get, 'https://openexchangerates.org/api/usage.json?app_id=XXX')
      .to_return status: 200, body: File.open(fixture('usage.json'))
    response = OXR.usage
    refute_nil response['data']['usage']['requests']
    refute_nil response['data']['usage']['requests_quota']
    refute_nil response['data']['usage']['requests_remaining']
  end

  def test_missing_app_id
    OXR.configure do |config|
      @app_id = config.app_id
      config.app_id = nil
    end
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=')
      .to_return status: 401, body: File.open(fixture('missing_app_id.json'))
    error = assert_raises(OXR::ApiError) { OXR['USD'] }
    assert_match(/No App ID provided/, error.description)
    assert_equal 'missing_app_id', error.response['message']
    assert_equal 401, error.response['status']
  ensure
    OXR.configure do |config|
      config.app_id = @app_id
    end
  end

  def test_invalid_app_id
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX')
      .to_return status: 401, body: File.open(fixture('invalid_app_id.json'))
    error = assert_raises(OXR::ApiError) { OXR['USD'] }
    assert_match(/Invalid App ID/, error.description)
    assert_equal 'invalid_app_id', error.response['message']
    assert_equal 401, error.response['status']
  end

  def test_access_restricted
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX')
      .to_return status: 429, body: File.open(fixture('access_restricted.json'))
    error = assert_raises(OXR::ApiError) { OXR['USD'] }
    assert_match(/Access restricted/, error.description)
    assert_equal 'access_restricted', error.response['message']
    assert_equal 429, error.response['status']
  end

  def test_invalid_base
    OXR.configure do |config|
      config.base = 'XXX'
    end
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX&base=XXX')
      .to_return status: 400, body: File.open(fixture('invalid_base.json'))
    error = assert_raises(OXR::ApiError) { OXR['USD'] }
    assert_match(/Invalid `base` currency \[XXX\]/, error.description)
    assert_equal 'invalid_base', error.response['message']
    assert_equal 400, error.response['status']
  end

  def fixture(file)
    File.expand_path File.join('fixtures', file), __dir__
  end
end

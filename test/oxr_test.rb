require 'test_helper'

class OXRTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OXR::VERSION
  end

  def test_latest
    stub_request(:get, 'https://openexchangerates.org/api/latest.json?app_id=XXX')
      .to_return status: 200, body: File.open('test/fixtures/latest.json')
    response = OXR.new('XXX').latest

    refute_nil response['timestamp']
    assert_equal 'USD', response['base']
    assert_equal 1, response['rates']['USD']
    refute_nil response['rates']['GBP']
  end

  def test_historical
    stub_request(:get, 'https://openexchangerates.org/api/historical/2015-06-14.json?app_id=XXX')
      .to_return status: 200, body: File.open('test/fixtures/historical.json')
    response = OXR.new('XXX').historical on: Date.new(2015, 6, 14)

    refute_nil response['timestamp']
    assert_equal 'USD', response['base']
    assert_equal 1, response['rates']['USD']
    refute_nil response['rates']['GBP']
  end

  def test_currencies
    stub_request(:get, 'https://openexchangerates.org/api/currencies.json?app_id=XXX')
      .to_return status: 200, body: File.open('test/fixtures/currencies.json')
    response = OXR.new('XXX').currencies

    assert_equal 'British Pound Sterling', response['GBP']
    assert_equal 'United States Dollar', response['USD']
  end

  def test_usage
    stub_request(:get, 'https://openexchangerates.org/api/usage.json?app_id=XXX')
      .to_return status: 200, body: File.open('test/fixtures/usage.json')
    response = OXR.new('XXX').usage

    refute_nil response['data']['usage']['requests']
    refute_nil response['data']['usage']['requests_quota']
    refute_nil response['data']['usage']['requests_remaining']
  end
end

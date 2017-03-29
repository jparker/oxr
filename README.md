# [![Gem Version](https://badge.fury.io/rb/oxr.svg)](https://badge.fury.io/rb/oxr) [![Build Status](https://travis-ci.org/jparker/oxr.svg?branch=master)](https://travis-ci.org/jparker/oxr)

# OXR

This gem provides a basic interface to the
[Open Exchange Rates](https://openexchangerates.org) API. At present, only the
API calls available to free plans have been implemented.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oxr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oxr

## Usage

If you have not done so already, sign up for account on
[Open Exchange Rates](https://openexchangerates.org). Once you have an account,
go to Your Dashboard and locate your App ID.

Configure OXR with your App ID by calling OXR.configure:

```ruby
OXR.configure do |config|
  config.app_id = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
end
```

(If you are using OXR within a Rails application, you will probably want to put
this in an initializer.)

You can get current exchange rates using `OXR.get_rate`:

```ruby
OXR.get_rate 'GBP' # => 0.703087
OXR.get_rate 'JPY' # => 111.7062
```

You can also use the `OXR.[]` shortcut method.

```ruby
OXR['GBP'] # => 0.703087
```

`OXR.get_rate` accepts an optional keyword argument to retrieve historical
exchange rates for given dates. The provided date should be an object which
responds to `#strftime`.

```ruby
OXR.get_rate 'GBP', on: Date.new(2015, 6, 14) # => 0.642607
```

You perform more complex operations by using the lower-level API calls. These
methods return the raw JSON responses returned by Open Exchange Rates (parsed
using the [json](https://rubygems.org/gems/json) gem).

Get the latest exchange rates with `OXR#latest`.

```ruby
OXR.latest
```

This will return a JSON object with a structure similar to the following:

```json
{
  "disclaimer": "…",
  "license": "…",
  "timestamp": 1234567890,
  "base": "USD",
  "rates": {
    "AED": 3.672995,
    "AFN": 68.360001,
    "ALL": 123.0332,
    /* … */
    "ZMK": 5252.024745,
    "ZMW": 11.332275,
    "ZWL": 322.387247
  }
}
```

Get historical exchange rates for specific dates with `OXR#historical`. This
method requires you to provide the date you wish to lookup. The date argument
should respond to `#strftime`.

```ruby
OXR.historical on: Date.new(2016, 3, 24)
```

This will return a JSON object with a structure similar to that returned by `OXR#latest`.

Get a list of available currencies with `OXR#currencies`.

```ruby
OXR.currencies
```

Get information about your account including your usage for the current period
with `OXR#usage`.

```ruby
OXR.usage
```

## Testing

Normally, any API call will send a request to Open Exchange Rates. Since your
plan allows a limited number of requests per month, you probably want to avoid
this when running in a test environment. You can stub the responses of specific
API calls by configuring the endpoint for specific calls to use a local file
instead of an HTTP request. Just provide a JSON file that reflects the payload
of an actual API call. (You will find usable JSON files in test/fixtures
included with this gem.)

When you're done, you can call `OXR.reset_sources` to restore the default behavior.

Below is an example of configuring OXR within a test.

```ruby
class SomeTest < Minitest::Test
  def setup
    OXR.configure do |config|
      config.latest = 'test/fixtures/sample.json'
    end
  end

  def teardown
    OXR.reset_sources
  end
end
```

(You might consider doing this in your development environment as well.)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jparker/oxr.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

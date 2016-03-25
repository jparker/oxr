# [![Gem Version](https://badge.fury.io/rb/oxr.svg)](https://badge.fury.io/rb/oxr) [![Build Status](https://travis-ci.org/jparker/oxr.svg?branch=master)](https://travis-ci.org/jparker/oxr)

# OXR

This gem provides a basic interface to the [Open Exchange Rates](https://openexchangerates.org) API.

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

If you have not done so already, sign up for account on [Open Exchange Rates](https://openexchangerates.org). Once you have an account, go to Your Dashboard and locate your App ID.

Instantiate a new OXR object, passing your App ID as an argument.

```ruby
oxr = OXR.new 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
```

The Open Exchange Rates API returns results as JSON objects. OXR parses these (using the [json](https://rubygems.org/gems/json)) and returns the resulting Hashes. To see the exact structure of the responses for different queries, check the [Open Exchange Rates documentation](https://docs.openexchangerates.org/) or examine the sample responses in `test/fixtures`.

Get the latest conversion rates with `OXR#latest`.

```ruby
oxr.latest
```

Get historical conversion rates for specific dates with `OXR#historical`. This method requires you to provide a Date object for the date you wish to query.

```ruby
oxr.historical on: Date.new(2016, 3, 24)
```

Get a list of currently supported currencies with `OXR#currencies`.

```ruby
oxr.currencies
```

Get information about your account (including your usage for the current period) with `OXR#usage`.

```ruby
oxr.usage
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jparker/oxr.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

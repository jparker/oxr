# frozen_string_literal: true

require 'oxr/version'
require 'oxr/configuration'

require 'date'
require 'json'
require 'open-uri'

##
# All use of OXR takes place through module methods.
#
# Before you can make API calls, you must configure OXR with your Open Exchange
# Rates App ID. Visit https://openexchangerates.org to sign up and generate one.
#
#   OXR.configure do |config|
#     config.app_id = 'XXXX'
#   end
#
# Optionally you may also specify the base currency for the conversion rates.
# The default base currency is USD.
#
#   OXR.configure do |config|
#     config.app_id = 'XXXX'
#     config.base = 'JPY'
#   end
#
# If you will be using OXR in a test environment, you may want to test the
# substitute local files for the API endpoints to provide deterministic results
# and avoid running over your Open Exchange Rates API request quota.
#
#   class ThisIsATest < Minitest::Test
#     def setup
#       OXR.configure do |config|
#         config.latest = 'test/fixtures/sample.json'
#       end
#     end
#
#     def teardown
#       OXR.reset_sources
#     end
#   end
#
# To quickly get an exchange rate from the base currency to a given currency,
# use `OXR.get_rate`.
#
#   OXR.get_rate 'GBP' # => 0.703087
#   OXR.get_rate 'JPY' # => 111.7062
#
# This method is aliased as `OXR.[]`.
#
#   OXR['GBP'] # => 0.703087
#
# Pass the `:on` keyword argument to get an historical exchange rate on a given
# date.
#
#   OXR.get_rate 'GBP', on: Date.new(2015, 6, 14) # => 0.642607
#
module OXR
  class Error < StandardError
  end

  ##
  # ApiError is raised when OXR encounters an error connecting to the Open
  # Exchange Rates API server.
  class ApiError < Error
    def message
      cause.message
    end

    def description
      response['description']
    end

    def response
      @response ||= JSON.parse cause.io.read
    end
  end

  class << self
    ##
    # DEPRECATED: TO BE REMOVED IN 0.7.
    #
    # OXR should no longer be instantiated explicitly.
    #
    # Call OXR.configure to specify the application ID and use the module
    # methods below to access the different API endpoints.
    def new(app_id)
      warn '[DEPRECATION] OXR.new is deprecated and will be removed from 0.7.' \
        " Use OXR class methods instead (from #{caller(1..1).first})."
      configure do |config|
        config.app_id = app_id
      end
      self
    end

    ##
    # Get the latest exchange rate for currency identified by +code+.
    #
    # If the optional +on+ keyword is provided, it instead returns the
    # historical exchange rate on the given date.
    def get_rate(code, on: nil)
      data = if on
               historical on: on
             else
               latest
             end
      data['rates'][code.to_s]
    end

    alias [] get_rate

    ##
    # Returns a Hash mapping currency codes to full currency names.
    def currencies
      call configuration.currencies
    end

    ##
    # Returns a Hash mapping currency codes to their historical exchange rate
    # on the date given by the +on+ keyword argument.
    #
    # The exchange rate is relative to the configured base currency.
    def historical(on:)
      call configuration.historical on
    end

    ##
    # Returns a Hash mapping currency codes to their latest exchange rate.
    #
    # The exchange rate is relative to the configured base currency.
    def latest
      call configuration.latest
    end

    ##
    # Returns a Hash containinng details about the Open Exchange Rates account
    # and current usage statistics.
    def usage
      call configuration.usage
    end

    ##
    # Resets API endpoints to their defaults.
    def reset_sources
      configure(&:reset_sources)
    end

    ##
    # Returns the OXR configuration struct.
    #
    # If given a block, the configuration will be yielded to the block.
    def configure
      yield configuration if block_given?
      configuration
    end

    ##
    # Returns the OXR configuration struct.
    def configuration
      @configuration ||= Configuration.new
    end

    private

    def call(endpoint)
      uri = URI.parse endpoint
      data = uri.scheme ? uri.read : File.read(uri.path)
      JSON.parse data
    rescue OpenURI::HTTPError => e
      raise ApiError, e
    end
  end
end

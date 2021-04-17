# frozen_string_literal: true

require 'uri'

module OXR
  ##
  # A container for OXR configuration options.
  #
  # Stores the API application ID and the base currency for which to request
  # exchange rates.
  #
  # Also stores the URI endpoints for fetching currencies, the latest exchange
  # ranges,  historical exchange rates, and current account usage statistics.
  #
  # By default, endpoints are generated dynamically, allowing them to
  # automatically adapte to changes to the app_id, but they may be set to a
  # fixed path, including a local file path. This is useful during testing when
  # you might want deterministic results and do not want to waste real API
  # requests.
  class Configuration
    ENDPOINT   = 'https://openexchangerates.org/api/'
    LATEST     = URI.join(ENDPOINT, 'latest.json').freeze
    HISTORICAL = URI.join(ENDPOINT, 'historical/').freeze
    USAGE      = URI.join(ENDPOINT, 'usage.json').freeze
    CURRENCIES = URI.join(ENDPOINT, 'currencies.json').freeze

    ##
    # Get and set the application ID that will be sent to the API server.
    attr_accessor :app_id

    ##
    # Get and set the base currency to be used when fetching exchange rates.
    attr_accessor :base

    ##
    # Set respective API endpoints. Use these if you want to sidestep the API
    # server, e.g., for testing. The endpoint may be provided as a URI,
    # Pathname, or String.
    #
    # Setting an endpoint to +nil+ will restore the default value.
    attr_writer :currencies, :historical, :latest, :usage

    def initialize
      reset_sources
    end

    ##
    # Returns the endpoint for listing known currencies.
    def currencies
      @currencies || append_query(CURRENCIES)
    end

    ##
    # Returns the endpoint for historical currency exchange rates on the given
    # date.
    #
    # Expects +date+ to respond #strftime.
    def historical(date)
      @historical || append_query(URI.join(HISTORICAL, "#{date.strftime('%F')}.json"), base: base)
    end

    ##
    # Returns the endpoint for the latest currency exchange rates.
    def latest
      @latest || append_query(LATEST, base: base)
    end

    ##
    # Returns the endpoint for fetch current API usage statistics.
    def usage
      @usage || append_query(USAGE)
    end

    ##
    # Resets all API endpoints back to their default (dynamic generation).
    def reset_sources
      @currencies = nil
      @historical = nil
      @latest     = nil
      @usage      = nil
    end

    private

    def append_query(uri, base: nil)
      uri.dup.tap do |u|
        u.query = "app_id=#{app_id}"
        u.query += "&base=#{base}" if base
      end.to_s
    end
  end
end

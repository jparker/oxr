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
    ENDPOINT = 'https://openexchangerates.org/api/'

    ##
    # Get and set the application ID that will be sent to the API server.
    attr_accessor :app_id

    ##
    # Get and set the base currency to be used when fetching exchange rates.
    attr_accessor :base

    ##
    # Set respective API endpoints. Use these if you want to sidestep the API
    # server, e.g., for testing.
    attr_writer :currencies, :historical, :latest, :usage

    def initialize
      reset_sources
    end

    ##
    # Returns the endpoint for listing known currencies.
    def currencies
      @currencies || URI.join(ENDPOINT, 'currencies.json').tap do |uri|
        uri.query = "app_id=#{app_id}"
      end.to_s
    end

    ##
    # Returns the endpoint for historical currency exchange rates on the given
    # date.
    #
    # Expects +date+ to respond #strftime.
    def historical(date)
      @historical || URI.join(ENDPOINT, "historical/#{date.strftime('%F')}.json").tap do |uri|
        uri.query = "app_id=#{app_id}"
        uri.query += "&base=#{base}" if base
      end.to_s
    end

    ##
    # Returns the endpoint for the latest currency exchange rates.
    def latest
      @latest || URI.join(ENDPOINT, 'latest.json').tap do |uri|
        uri.query = "app_id=#{app_id}"
        uri.query += "&base=#{base}" if base
      end.to_s
    end

    ##
    # Returns the endpoint for fetch current API usage statistics.
    def usage
      @usage || URI.join(ENDPOINT, 'usage.json').tap do |uri|
        uri.query = "app_id=#{app_id}"
      end.to_s
    end

    ##
    # Resets all API endpoints back to their default (dynamic generation).
    def reset_sources
      @currencies = nil
      @historical = nil
      @latest     = nil
      @usage      = nil
    end
  end
end

# frozen_string_literal: true

require 'uri'

module OXR
  class Configuration
    ENDPOINT = 'https://openexchangerates.org/api/'.freeze

    attr_accessor :app_id, :base
    attr_writer :currencies, :historical, :latest, :usage

    def initialize
      reset_sources
    end

    def currencies
      @currencies || URI.join(ENDPOINT, 'currencies.json').tap do |uri|
        uri.query = "app_id=#{app_id}"
      end.to_s
    end

    def historical(date)
      @historical || URI.join(ENDPOINT, "historical/#{date.strftime('%F')}.json").tap do |uri|
        uri.query = "app_id=#{app_id}"
        uri.query += "&base=#{base}" if base
      end.to_s
    end

    def latest
      @latest || URI.join(ENDPOINT, 'latest.json').tap do |uri|
        uri.query = "app_id=#{app_id}"
        uri.query += "&base=#{base}" if base
      end.to_s
    end

    def usage
      @usage || URI.join(ENDPOINT, 'usage.json').tap do |uri|
        uri.query = "app_id=#{app_id}"
      end.to_s
    end

    def reset_sources
      @currencies = nil
      @historical = nil
      @latest     = nil
      @usage      = nil
    end
  end
end

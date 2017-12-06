require 'uri'

module OXR
  class Configuration
    ENDPOINT = 'https://openexchangerates.org/api/'

    attr_accessor :app_id, :base
    attr_writer :currencies, :historical, :latest, :usage

    def currencies
      @currencies ||= URI.join(ENDPOINT, 'currencies.json').tap { |uri|
        uri.query = "app_id=#{app_id}"
      }.to_s
    end

    def historical(date)
      @historical ||= URI.join(ENDPOINT, "historical/#{date.strftime('%F')}.json").tap { |uri|
        uri.query = "app_id=#{app_id}"
        uri.query += "&base=#{base}" if base
      }.to_s
    end

    def latest
      @latest ||= URI.join(ENDPOINT, 'latest.json').tap { |uri|
        uri.query = "app_id=#{app_id}"
        uri.query += "&base=#{base}" if base
      }.to_s
    end

    def usage
      @usage ||= URI.join(ENDPOINT, 'usage.json').tap { |uri|
        uri.query = "app_id=#{app_id}"
      }.to_s
    end

    def reset_sources
      @currencies = nil
      @historical = nil
      @latest     = nil
      @usage      = nil
    end
  end
end

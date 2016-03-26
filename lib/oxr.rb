require "oxr/version"

require 'date'
require 'json'
require 'open-uri'

class OXR
  BASE_PATH = 'https://openexchangerates.org/api/'.freeze

  class OXRError < StandardError
    def initialize(message, response)
      super message
      @response = response
    end

    attr_reader :response
  end

  def initialize(app_id)
    @app_id = app_id
  end

  attr_reader :app_id

  def latest(only: nil, endpoint: nil)
    endpoint ||= URI.join(BASE_PATH, 'latest.json').tap { |uri|
      uri.query  = "app_id=#{app_id}"
      uri.query += "&symbols=#{Array(only).join ','}" if only
    }
    call endpoint
  end

  def historical(on:, only: nil, endpoint: nil)
    endpoint ||= begin
                   date = on.strftime '%Y-%m-%d'
                   URI.join(BASE_PATH, 'historical/', "#{date}.json").tap { |uri|
                     uri.query = "app_id=#{app_id}"
                     uri.query += "&symbols=#{Array(only).join ','}" if only
                   }
                 end
    call endpoint
  end

  def currencies(endpoint: nil)
    endpoint ||= URI.join(BASE_PATH, 'currencies.json').tap { |uri|
      uri.query = "app_id=#{app_id}"
    }
    call endpoint
  end

  def usage(endpoint: nil)
    endpoint ||= URI.join(BASE_PATH, 'usage.json').tap { |uri|
      uri.query = "app_id=#{app_id}"
    }
    call endpoint
  end

  private

  def call(endpoint)
    JSON.load open endpoint
  rescue OpenURI::HTTPError => e
    case e.message
    when /\A4[[:digit:]]{2}/
      response = JSON.load e.io
      raise OXRError.new response['description'], response
    else
      raise
    end
  end
end

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

  def latest(only: nil)
    endpoint        = URI.join BASE_PATH, 'latest.json'
    endpoint.query  = "app_id=#{app_id}"
    # Only allowed for paid plans
    endpoint.query += "&symbols=#{Array(only).join ','}" if only
    call endpoint
  end

  def historical(on:, only: nil)
    date = on.strftime '%Y-%m-%d'
    endpoint = URI.join BASE_PATH, 'historical/', "#{date}.json"
    endpoint.query = "app_id=#{app_id}"
    # Only allowed for paid plans
    endpoint.query += "&symbols=#{Array(only).join ','}" if only
    call endpoint
  end

  def currencies
    endpoint = URI.join BASE_PATH, 'currencies.json'
    endpoint.query = "app_id=#{app_id}"
    call endpoint
  end

  def usage
    endpoint = URI.join BASE_PATH, 'usage.json'
    endpoint.query = "app_id=#{app_id}"
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

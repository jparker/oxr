require "oxr/version"

require 'date'
require 'json'
require 'open-uri'

class OXR
  BASE_PATH = 'https://openexchangerates.org/api/'.freeze

  def initialize(app_id)
    @app_id = app_id
  end

  attr_reader :app_id

  def latest(only: nil)
    endpoint        = URI.join BASE_PATH, 'latest.json'
    endpoint.query  = "app_id=#{app_id}"
    # Only allowed for paid plans
    endpoint.query += "&symbols=#{Array(only).join ','}" if only
    JSON.load open endpoint
  end

  def historical(on:, only: nil)
    date = on.strftime '%Y-%m-%d'
    endpoint = URI.join BASE_PATH, 'historical/', "#{date}.json"
    endpoint.query = "app_id=#{app_id}"
    # Only allowed for paid plans
    endpoint.query += "&symbols=#{Array(only).join ','}" if only
    JSON.load open endpoint
  end

  def currencies
    endpoint = URI.join BASE_PATH, 'currencies.json'
    endpoint.query = "app_id=#{app_id}"
    JSON.load open endpoint
  end

  def usage
    endpoint = URI.join BASE_PATH, 'usage.json'
    endpoint.query = "app_id=#{app_id}"
    JSON.load open endpoint
  end
end

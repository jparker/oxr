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

  def latest
    endpoint = sources[:latest] || build_uri_endpoint('latest.json')
    call endpoint
  end

  def historical(on:)
    endpoint = sources[:historical] || \
      build_uri_endpoint('historical/', "#{on.strftime '%Y-%m-%d'}.json")
    call endpoint
  end

  def currencies
    endpoint = sources[:currencies] || build_uri_endpoint('currencies.json')
    call endpoint
  end

  def usage
    endpoint= sources[:usage] || build_uri_endpoint('usage.json')
    call endpoint
  end

  private

  def build_uri_endpoint(*path, **params)
    URI.join(BASE_PATH, *path).tap do |uri|
      uri.query = "app_id=#{app_id}"
    end
  end

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

  def sources
    self.class.sources
  end

  def self.sources
    @sources ||= {}
  end

  def self.reset_sources
    sources.clear
  end
end

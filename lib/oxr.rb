require 'oxr/version'
require 'oxr/configuration'

require 'date'
require 'json'
require 'open-uri'

module OXR
  class Error < StandardError
  end

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
    def new(app_id)
      warn '[DEPRECATION WARNING] OXR.new is deprecated.' \
        " Use OXR class methods instead (from #{caller(1..1).first})."
      configure do |config|
        config.app_id = app_id
      end
      self
    end

    def get_rate(code, on: nil)
      data = if on
               historical on: on
             else
               latest
             end
      data['rates'][code.to_s]
    end

    alias [] get_rate

    def currencies
      call configuration.currencies
    end

    def historical(on:)
      call configuration.historical on
    end

    def latest
      call configuration.latest
    end

    def usage
      call configuration.usage
    end

    def reset_sources
      configure(&:reset_sources)
    end

    def configure
      yield configuration if block_given?
      configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    private

    def call(endpoint)
      JSON.parse(URI.open(endpoint).read)
    rescue OpenURI::HTTPError => e
      raise ApiError, e
    end
  end
end

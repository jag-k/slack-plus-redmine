require 'net/https'
require 'uri'
require 'json'

module Redmine
  TOKEN = ENV['REDMINE_TOKEN']
  DOMAIN = ENV['REDMINE_DOMAIN']

  class RequestSender
    # @param url [String] URL to request Redmine API
    def initialize(url)
      @url = url
    end

    # @return [Hash] Result
    def call
      uri = URI.parse(url)

      request = Net::HTTP::Get.new(url)
      request['X-Redmine-API-Key'] = TOKEN
      request["Content-Type"] = "application/json"

      begin
        Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
          response = http.request request
          return JSON.parse(response.body, { symbolize_names: true })
        end
      rescue JSON::ParseException
        return
      end
    end

    private

    attr_reader :url
  end
end

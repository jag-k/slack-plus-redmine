require 'net/https'
require 'uri'
require 'json'

module Redmine
  class RequestSender
    TOKEN = ENV['REDMINE_TOKEN']

    def initialize(url)
        @url = url
    end

    def call
        uri = URI.parse(url)

        request = Net::HTTP::Get.new(url)
        request['X-Redmine-API-Key'] = TOKEN
        request["Content-Type"] = "application/json"

        Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
          response = http.request request
          JSON.parse(response.body, { symbolize_names: true })
        end
    end

    private

    attr_reader :url
  end
end

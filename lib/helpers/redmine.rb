require 'net/https'
require 'uri'
require 'json'

module Redmine
  @domain = ENV['REDMINE_DOMAIN']
  @token = ENV['REDMINE_TOKEN']

  # @param [String] url
  # @return [Hash]
  def find(url)
    uri = URI.parse(url)
    request = Net::HTTP::Get.new(url)

    request['X-Redmine-API-Key'] = @token
    request["Content-Type"] = "application/json"

    Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) { |http|
      response = http.request request
      JSON.parse(response.body, { symbolize_names: true })
    }
  end

  # @param [Numeric] issue_id
  # @return [Hash]
  def issue(issue_id)
    (find "#{@domain}/issues/#{issue_id}.json?include=journals,custom_fields")[:issue]
  end

  # @param [Numeric] user_id
  # @return [Hash]
  def user(user_id)
    (find "#{@domain}/users/#{user_id}.json")[:user]
  end
end
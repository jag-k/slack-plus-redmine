# frozen_string_literal: true

module Redmine
  class IssueInfo
    DOMAIN = ENV['REDMINE_DOMAIN']

    def initialize(issue_id)
      @issue_id = issue_id
    end

    def call
      url = "#{DOMAIN}/issues/#{issue_id}.json?include=journals,custom_fields"
      redmine_response = Redmine::RequestSender.new(url).call

      redmine_response[:issue]
    end

    private

    attr_reader :issue_id
  end
end

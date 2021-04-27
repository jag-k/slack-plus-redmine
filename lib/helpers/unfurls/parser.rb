module Unfurls
  class Parser

    # @param url [String] Issue URL
    def initialize(url)
      @url = url
    end

    # @return [Integer, null] Issue ID if URL is valid
    def call
      if url.start_with? Redmine::ISSUE_URL
        issue_id = url.slice(Redmine::ISSUE_URL.length..url.length).split(/\//)[0]
        if /\A[-+]?\d+\z/ === issue_id
          issue_id
        end
      end
    end

    private

    attr_reader :url
  end
end

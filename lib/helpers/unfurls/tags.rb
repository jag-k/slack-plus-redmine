module Unfurls
  class Tags
    # @param issue [Hash] Issue object
    def initialize(issue)
      @issue = issue
    end

    # @return [String] Tags string
    def call
      issue[:journals].map { |elem|
        elem[:details].filter { |detail|
          detail[:name] == "tag_list"
        }.map { |value|
          value[:new_value]
        }
      }.filter { |elem| elem.present? }.last
    end

    private

    attr_reader :issue
  end
end
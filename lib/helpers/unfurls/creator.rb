module Unfurls
  class Creator
    # @param url [String] Issue url
    def initialize(url)
      @url = url
    end

    # @return [String] unfurls json
    def call
      issue_id = Parser.new(url).call
      if issue_id.present?
        issue = Redmine::Issue.new(issue_id).call

        {
          url => {
            "blocks": [
              header(issue),
              section(issue)
            ]
          }
        }.to_json
      end
    end

    private

    # @param [Hash] issue Issue Hash-object
    def header(issue)
      {
        "type": "header",
        "text": {
          "type": "plain_text",
          "text": "##{issue[:id]}: #{issue[:subject]}"
        }
      }
    end

    # @param [Hash] issue Issue Hash-object
    # @param [Hash] assigned_to Redmine User
    def fields(issue, assigned_to)
      author = Redmine::User.new(issue[:author][:id]).call
      tags = Tags.new(issue).call

      fields_array = [
        { name: "Author", value: author[:link] },
        { name: "Assigned To", value: assigned_to[:link] },
        { name: "Estimated Time", value: "#{issue[:estimated_hours]} h." },
        { name: "Spend time", value: "#{issue[:spent_hours]} h." },
        { name: "Tags", value: tags }
      ]
      fields_array.concat issue[:custom_fields]
      Fields.new(fields_array).call
    end

    # @param [Hash] issue Issue Hash-object
    def section(issue)
      assigned_to = Redmine::User.new(issue[:assigned_to][:id]).call
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": fields(issue, assigned_to)
        },
        "accessory": {
          "type": "image",
          "image_url": assigned_to[:avatar],
          "alt_text": "Assigned to #{assigned_to[:name]}"
        }
      }
    end

    attr_reader :url
  end
end
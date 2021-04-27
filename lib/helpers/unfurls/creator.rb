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
        assigned_to = Redmine::User.new(issue[:assigned_to][:id]).call
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
        fields = Fields.new(fields_array).call

        {
          url => {
            "blocks": [
              {
                "type": "header",
                "text": {
                  "type": "plain_text",
                  "text": "##{issue_id}: #{issue[:subject]}"
                }
              },
              {
                "type": "section",
                "text": {
                  "type": "mrkdwn",
                  "text": fields
                },
                "accessory": {
                  "type": "image",
                  "image_url": assigned_to[:avatar],
                  "alt_text": "Assigned to #{assigned_to[:name]}"
                }
              }
            ]
          }
        }.to_json
      end
    end

    private

    attr_reader :url
  end
end
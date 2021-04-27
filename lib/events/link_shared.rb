REDMINE_DOMAIN = ENV['REDMINE_DOMAIN']
ISSUE_URL = "#{REDMINE_DOMAIN}/issues/"
USERS_URL = "#{REDMINE_DOMAIN}/users/".freeze
REVIEWER = 'Ревьюер'.freeze

SlackRubyBotServer::Events.configure do |config|
  config.on :event, 'event_callback', 'link_shared' do |event|
    event[:event][:links].each do |link|
      if link[:url].start_with? ISSUE_URL
        issue_id = link[:url].slice(ISSUE_URL.length..link[:url].length).split(/\//)[0]
        if issue_id.is_i?
          issue = Redmine.issue issue_id
          assigned_to = Redmine.user issue[:assigned_to][:id]

          tags = issue[:journals].map { |elem|
            elem[:details].filter { |detail|
              detail[:name] == "tag_list"
            }.map { |value|
              value[:new_value]
            }
          }.filter { |elem| elem.present? }.last

          issue[:custom_fields].push({ name: "Tags", value: tags })


          custom_fields = issue[:custom_fields].filter {
            |elem| elem[:value].present?
          }.map {
            |elem| "#{elem[:name]}: #{elem[:value].kind_of?(Array) ? elem[:value].join(', ') : elem[:value]}"
          }.join "\n"

          custom_fields_array = issue[:custom_fields].each_with_object([]) do |(name, value), acc|
            next if value.blank?

            field_value = if value.is_a?(Array)
                            value.join(', ')
                          elsif  name == REVIEWER
                            "#{USERS_URL}#{value}" # как пример
                          else
                            value
                          end

            acc << "#{name}: #{field_value}"
          end

          custom_fields = custom_fields_array.join("\n")

          author_text = "<#{USERS_URL}#{issue[:author][:id]}|#{issue[:author][:name]}>"
          assignee_text = "<#{USERS_URL}#{issue[:assigned_to][:id]}|#{issue[:assigned_to][:name]}>"

          unfurls = {
            link[:url] => {
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
                    "text": "Status: #{issue[:status][:name]}\n"\
                            "Author: #{author_text}\n"\
                            "Assigned To: #{assignee_text}\n"\
                            "Estimated Time: #{issue[:estimated_hours]} h.\n"\
                            "Spend time: #{issue[:spent_hours]} h.\n"\
                            "#{custom_fields}"
                  },
                  "accessory": {
                    "type": "image",
                    "image_url": gavatar(assigned_to[:mail] || "#{assigned_to[:login]}@okdesk.ru"),
                    "alt_text": "Assigned to #{issue[:assigned_to][:name]}"
                  }
                }
              ]
            }
          }.to_json

          Slack::Web::Client.new(token: ENV['SLACK_TOKEN']).chat_unfurl(
            channel: event[:event][:channel],
            ts: event[:event][:message_ts],
            unfurls: unfurls
          )
        end
      end
    end
    true
  end

  config.on :event, 'event_callback' do |event|
    # handle any event callback
    false
  end

  config.on :event do |event|
    # handle any event[:event][:type]
    false
  end
end

REDMINE_DOMAIN = ENV['REDMINE_DOMAIN']
ISSUE_URL = "#{REDMINE_DOMAIN}/issues/"

SlackRubyBotServer::Events.configure do |config|
  config.on :event, 'event_callback', 'link_shared' do |event|
    event[:event][:links].each do |link|
      event.logger.info link[:url]
      event.logger.info link[:url].start_with? ISSUE_URL
      if link[:url].start_with? ISSUE_URL
        issue_id = link[:url].slice(ISSUE_URL.length..link[:url].length).split(/\//)[0]
        event.logger.info issue_id
        if issue_id.is_i?
          issue = redmine_issue issue_id
          assigned_to = redmine_user issue[:assigned_to][:id]
          # tags = issue[:journals].filter  { |elem|
          #   elem[:details][0][:name] == "tag_list"
          # }.map { |value| value[:details][0][:new_value]}
          # event.logger.info tags.to_json
          custom_fields = issue[:custom_fields].filter {
            |elem| elem[:value].present?
          }.map {
            |elem| "#{elem[:name]}: #{elem[:value]}"
          }.join "\n"

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
                            "Author: <#{REDMINE_DOMAIN}/users/#{issue[:author][:id]}|#{issue[:author][:name]}>\n"\
                            "Assigned To: <#{REDMINE_DOMAIN}/users/#{issue[:assigned_to][:id]}|#{issue[:assigned_to][:name]}>\n"\
                            "Estimated Time: #{issue[:estimated_hours]} h.\n"\
                            "Spend time: #{issue[:spent_hours]} h.\n"\
                            "#{custom_fields}"
                  },
                  "accessory": {
                    "type": "image",
                    "image_url": gavatar(assigned_to[:mail] || assigned_to[:login] + '@okdesk.ru'),
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
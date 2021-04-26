REDMINE_DOMAIN = ENV['REDMINE_DOMAIN']

SlackRubyBotServer::Events.configure do |config|
  config.on :event, 'event_callback', 'link_shared' do |event|
    event[:event][:links].each do |link|
      event.logger.info link[:url]
      if link[:url].start_with? REDMINE_DOMAIN
        issue_id = link[:url].split(/\//)[-1]
        if issue_id.is_i?
          issue = redmine_issue issue_id
          assigned_to = redmine_user issue[:assigned_to][:id]

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
                    "text": "Tracker: #{issue[:tracker][:name]}\n"\
                              "Status: #{issue[:status][:name]}\n"\
                              "Author: <#{REDMINE_DOMAIN}/users/#{issue[:author][:id]}|#{issue[:author][:name]}>\n"\
                              "Assigned To: <#{REDMINE_DOMAIN}/users/#{issue[:assigned_to][:id]}|#{issue[:assigned_to][:name]}>",
                  },
                  "accessory": {
                    "type": "image",
                    "image_url": gavatar(assigned_to[:mail] || assigned_to[:login] + '@okdesk.ru'),
                    "alt_text": "Assigned to #{issue[:assigned_to][:name]}"
                  }
                },
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": issue[:description] != "" ? issue[:description] : "No description"
                  }
                }
              ]
            }
          }.to_json

          puts unfurls

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
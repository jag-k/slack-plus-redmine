SlackRubyBotServer::Events.configure do |config|
  config.on :event, 'event_callback', 'link_shared' do |event|
    event[:event][:links].each do |link|
      unfurls = Unfurls::Creator.new(link[:url]).call
      if unfurls.present?
        Slack::Web::Client.new(token: ENV['SLACK_TOKEN']).chat_unfurl(
          channel: event[:event][:channel],
          ts: event[:event][:message_ts],
          unfurls: unfurls
        )
      end
    end
    true
  end
end

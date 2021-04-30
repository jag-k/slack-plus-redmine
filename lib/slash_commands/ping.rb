SlackRubyBotServer::Events.configure do |config|
  config.on :command, '/redmine-me' do |command|
    command.logger.info 'Add association Slack user with Redmine'
    command.logger.info command
    if /\A[-+]?\d+\z/ === command[:text]
      text = command[:text].strip
      redmine_user = Redmine::User.new(text).call
      command.logger.info redmine_user
      command.logger.info redmine_user.empty?
      if redmine_user.empty?
        { text: "User with id <#{Redmine::USERS_URL}#{text}|#{text}> not found!" }
      else
          user = User.new(slack_id: command[:user_id], name: command[:user_name], redmine_id: redmine_user[:id])
        command.logger.info user
        { text: "You (@#{user[:slack_id]}) be associated with Redmine user #{redmine_user[:name]}" }
      end
    else
      { text: "Done" }
    end
  end
end

# frozen_string_literal: true

module Redmine
  MAIL_DOMAIN = ENV['MAIL_DOMAIN'] || 'okdesk.ru'
  USERS_URL = "#{DOMAIN}/users/".freeze

  class User
    # @param user_id [String, Integer] Redmine User ID
    def initialize(user_id)
      @user_id = user_id
    end

    # @return [Hash] User Hash-object
    def call
      url = "#{USERS_URL}#{user_id}.json"
      redmine_response = Redmine::RequestSender.new(url).call
      if redmine_response.present?
      user = redmine_response[:user]

      user[:name] = user[:firstname].present? ? "#{user[:firstname]} #{user[:lastname]}" : user[:login]
      user[:mail] = user[:mail].present? ? user[:mail] : "#{user[:login]}@#{MAIL_DOMAIN}"
      user[:link] = "<#{Redmine::USERS_URL}#{user[:id]}|#{user[:name]}>"
      user[:avatar] = "https://www.gravatar.com/avatar/#{user[:mail].downcase.to_md5}?rating=PG&size=100&default=monsterid"
      user
      else
        {}
      end
    end

    private

    attr_reader :user_id
  end
end

# frozen_string_literal: true

class User < ActiveRecord::Base
  attr_accessor :slack_id, :ruby_id
  validates :slack_id, presence: true
  validates :ruby_id, presence: true

  def get_data
    Redmine::User.new(ruby_id).call
  end
end

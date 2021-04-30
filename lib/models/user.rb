class User < ActiveRecord::Base
  validates :slack_id, presence: true
  validates :redmine_id, presence: true

  def get_data
    Redmine::User.new(self.redmine_id).call
  end
end

class PublicSlackMessage < ActiveRecord::Base
  belongs_to :user
  def self.active_last_hour
    PublicSlackMessage.where('created_at > ?', 1.hour.ago).select(:slack_username).distinct.count
  end
end

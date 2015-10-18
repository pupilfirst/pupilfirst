class PublicSlackMessage < ActiveRecord::Base
  belongs_to :user
  def self.users_active_last_hour
    User.where(id: PublicSlackMessage.where('created_at > ?', 1.hour.ago).select(:user).distinct.pluck(:user_id))
  end
end

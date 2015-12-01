class PublicSlackMessage < ActiveRecord::Base
  belongs_to :user
  has_one :karma_point, as: :source

  def self.users_active_last_hour
    User.where(id: PublicSlackMessage.where('created_at > ?', 1.hour.ago).select(:user).distinct.pluck(:user_id))
  end

  def self.available_channels
    all.pluck(:channel).uniq
  end
end

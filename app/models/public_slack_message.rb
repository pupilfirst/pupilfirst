class PublicSlackMessage < ActiveRecord::Base
  belongs_to :user
  has_one :karma_point, as: :source

  has_many :reactions, class_name: PublicSlackMessage, foreign_key: 'parent_message_id'
  belongs_to :parent_message, class_name: PublicSlackMessage

  def self.users_active_last_hour
    User.where(id: PublicSlackMessage.where('created_at > ?', 1.hour.ago).select(:user).distinct.pluck(:user_id))
  end

  def self.available_channels
    all.pluck(:channel).uniq
  end
end

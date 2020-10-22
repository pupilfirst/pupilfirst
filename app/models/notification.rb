class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, class_name: 'User', optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  enum :object => { topic_created: "topic_created", topic_updated: "topic_updated" }

  scope :unread, -> { where(read_at: nil) }
end


class Notification < ApplicationRecord
  include PgSearch::Model
  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, class_name: 'User', optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  enum :event => { topic_created: "topic.created", topic_edited: "topic.edited" }

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  NOTIFICATION_READ = :read
  NOTIFICATION_UNREAD = :unread

  VALID_STATUS_TYPES = [
    NOTIFICATION_READ,
    NOTIFICATION_UNREAD
  ].freeze

  pg_search_scope :search_by_message, against: :message, using: { tsearch: { prefix: true, any_word: true }, }
end


class Event < ActiveRecord::Base
  belongs_to :location
  belongs_to :category
  belongs_to :author, class_name: 'AdminUser', foreign_key: :user_id
  mount_uploader :picture, FeedImageUploader
  process_in_background :picture

  just_define_datetime_picker :start_at
  just_define_datetime_picker :end_at

  normalize_attributes :title, :description, :start_at, :end_at, :featured, :picture, :notification_sent

  validates_presence_of :title
  validates_presence_of :author
  validates_presence_of :location
  validates_presence_of :category
  validates_presence_of :picture
  validates_presence_of :start_at
  validates_presence_of :end_at

  alias_attribute :push_title, :title

  PUSH_TYPE = "event" unless defined?(PUSH_TYPE)

  after_save do
    send_push_notification if featured_changed? and featured and not notification_sent
  end

  def send_push_notification
    PushNotifyJob.new.async.perform(self.class.to_s.downcase, self.id)
  end
end

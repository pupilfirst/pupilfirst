class Event < ActiveRecord::Base

  phony_normalize :posters_phone_number, default_country_code: 'IN'

  belongs_to :location
  belongs_to :category
  belongs_to :author, class_name: 'AdminUser', foreign_key: :user_id

  mount_uploader :picture, FeedImageUploader
  process_in_background :picture

  just_define_datetime_picker :start_at
  just_define_datetime_picker :end_at

  normalize_attributes :title, :description, :start_at, :end_at, :featured, :picture, :notification_sent

  validates_presence_of :title, :description, :location_id, :category_id, :picture, :start_at, :end_at, :posters_name
  validates_length_of :title, maximum: 50

  validates :posters_email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :posters_phone_number, presence: true, phony_plausible: true

  validate :start_date_greater_that_today

  def start_date_greater_that_today
    unless start_at.nil?
      if start_at < Time.now
        errors.add(:start_at, 'cannot be a past date')
      end
    end
  end

  validate :end_date_is_after_start_date

  def end_date_is_after_start_date
    unless start_at.nil? || end_at.nil?
      if end_at < start_at
        errors.add(:end_at, 'cannot be before the start date')
      end
    end
  end

  alias_attribute :push_title, :title

  PUSH_TYPE = 'event' unless defined?(PUSH_TYPE)

  after_save do
    send_push_notification! if featured_changed? and featured and not notification_sent
    send_approval_notification! if approved_changed? and approved and not approval_notification_sent
  end

  def send_push_notification!
    PushNotifyJob.new.async.perform(self.class.to_s.downcase, self.id)
    update!(notification_sent: true)
  end

  def send_approval_notification!
    EventMailer.event_approved_email(self).deliver
    update!(approval_notification_sent: true)
  end
end

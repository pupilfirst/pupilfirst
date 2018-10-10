class StartupFeedback < ApplicationRecord
  belongs_to :startup
  belongs_to :faculty
  belongs_to :timeline_event, optional: true
  attr_accessor :send_email, :event_id, :event_status

  # mount uploader for attachment
  mount_uploader :attachment, StartupFeedbackAttachmentUploader

  validates :feedback, presence: true

  normalize_attribute :activity_type

  # Returns all feedback for a given timeline event.
  def self.for_timeline_event(event)
    where(timeline_event: event).order('updated_at desc')
  end

  def attachment_file_name
    attachment? ? attachment.sanitized_file.original_filename : nil
  end

  def for_founder?
    timeline_event.present? ? timeline_event.founder_event? : false
  end
end

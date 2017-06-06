class StartupFeedback < ApplicationRecord
  belongs_to :startup
  belongs_to :faculty
  belongs_to :timeline_event
  attr_accessor :send_email, :event_id, :event_status

  scope :for_batch, ->(batch) { joins(:startup).where(startups: { batch_id: batch.id }) }
  scope :for_batch_id_in, ->(ids) { joins(:startup).where(startups: { batch_id: ids }) }

  # mount uploader for attachment
  mount_uploader :attachment, StartupFeedbackAttachmentUploader

  validates :faculty_id, presence: true
  validates :feedback, presence: true
  validates :startup_id, presence: true

  REGEX_TIMELINE_EVENT_URL = %r{startups/.*event-(?<event_id>[\d]+)}

  normalize_attribute :activity_type

  # Returns all feedback for a given timeline event.
  def self.for_timeline_event(event)
    where('reference_url LIKE ?', "%event-#{event.id}").order('updated_at desc')
  end

  def for_timeline_event?
    if reference_url.present? && reference_url.match(REGEX_TIMELINE_EVENT_URL).present?
      true
    else
      false
    end
  end

  def as_slack_message
    formatted_reference_url = reference_url.present? ? "<#{reference_url}|recent update>" : "recent update"
    salutation = "Hey! You have some feedback from #{faculty.name} on your #{formatted_reference_url}.\n"
    feedback_url = Rails.application.routes.url_helpers.startup_url(startup, show_feedback: id)
    feedback_text = "<#{feedback_url}|Click here> to view the feedback."
    salutation + feedback_text
  end

  def attachment_file_name
    attachment? ? attachment.sanitized_file.original_filename : nil
  end

  def for_founder?
    for_timeline_event? && timeline_event&.founder_event?
  end
end

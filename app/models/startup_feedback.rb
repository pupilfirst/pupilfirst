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

  def as_slack_message
    formatted_reference_url = reference_url.present? ? "<#{reference_url}|recent update>" : "recent update"
    salutation = "Hey! You have some feedback from #{faculty.name} on your #{formatted_reference_url}.\n"
    feedback_url = Rails.application.routes.url_helpers.timeline_url(startup.id, startup.slug, show_feedback: id)
    feedback_text = "<#{feedback_url}|Click here> to view the feedback."
    salutation + feedback_text
  end

  def attachment_file_name
    attachment? ? attachment.sanitized_file.original_filename : nil
  end

  def for_founder?
    timeline_event.present? && timeline_event&.founder_event?
  end
end

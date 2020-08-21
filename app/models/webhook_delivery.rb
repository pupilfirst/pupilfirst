class WebhookDelivery < ApplicationRecord
  belongs_to :school

  scope :pending, -> { where.not(sent_at: nil) }

  SUBMISSION_CREATED_EVENT = 'submission.created'

  def self.valid_event_types
    [SUBMISSION_CREATED_EVENT].freeze
  end
end

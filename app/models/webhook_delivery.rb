class WebhookDelivery < ApplicationRecord
  belongs_to :course

  scope :pending, -> { where.not(sent_at: nil) }

  enum event: { submission_created: "submission.created" }
end

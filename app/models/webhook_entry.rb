class WebhookEntry < ApplicationRecord
  belongs_to :school

  scope :pending, -> { where.not(sent_at: nil) }
end

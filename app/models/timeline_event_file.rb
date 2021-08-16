class TimelineEventFile < ApplicationRecord
  belongs_to :timeline_event, optional: true
  has_one_attached :file, service: :amazon_private

  validates :file, attached: true

  delegate :filename, to: :file
end

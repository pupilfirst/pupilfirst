class TimelineEventFile < ApplicationRecord
  belongs_to :timeline_event, optional: true
  has_one_attached :file

  validates :file, attached: true

  delegate :filename, to: :file
end

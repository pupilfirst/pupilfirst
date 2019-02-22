class TimelineEventFile < ApplicationRecord
  belongs_to :timeline_event
  has_one_attached :file_as

  validates :file_as, attached: true

  def filename
    file_as.filename
  rescue Errno::ENOENT => e
    raise e unless Rails.env.development?

    'missing_in_development'
  end
end

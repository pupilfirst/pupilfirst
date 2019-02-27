class TimelineEventFile < ApplicationRecord
  belongs_to :timeline_event
  has_one_attached :file

  validates :file, attached: true

  def filename
    file.filename
  rescue Errno::ENOENT => e
    raise e unless Rails.env.development?

    'missing_in_development'
  end
end

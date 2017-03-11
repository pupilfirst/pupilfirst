class TimelineEventFile < ApplicationRecord
  belongs_to :timeline_event

  mount_uploader :file, TimelineEventFileUploader

  validates :file, presence: true
  validates :title, presence: true

  # File is stored as private on S3. So we need to retrieve the name another way; not the usual column.file.filename.
  def filename
    file.sanitized_file.original_filename
  rescue Errno::ENOENT => e
    raise e unless Rails.env.development?
    'missing_in_development'
  end
end

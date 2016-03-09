class TimelineEventFile < ActiveRecord::Base
  belongs_to :timeline_event

  mount_uploader :file, TimelineEventFileUploader

  validates_presence_of :file, :timeline_event_id

  # File is stored as private on S3. So we need to retrieve the name another way; not the usual column.file.filename.
  def filename
    file.sanitized_file.original_filename
  end
end

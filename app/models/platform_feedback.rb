class PlatformFeedback < ActiveRecord::Base
  belongs_to :founder
  has_one :karma_point, as: :source

  mount_uploader :attachment, PlatformFeedbackAttachmentUploader

  validates_presence_of :founder

  def self.types_of_feedback
    %w(Feature Suggestion Bug Other)
  end

  validates :feedback_type, inclusion: types_of_feedback

  def attachment_filename
    attachment.sanitized_file.original_filename
  end
end

class PlatformFeedback < ApplicationRecord
  belongs_to :founder
  has_one :karma_point, as: :source

  scope :promoters, -> { where('promoter_score > ?', 8) }
  scope :detractors, -> { where('promoter_score < ?', 7) }
  scope :scored, -> { where.not(promoter_score: nil) }

  mount_uploader :attachment, PlatformFeedbackAttachmentUploader

  def self.types_of_feedback
    %w[Feature Suggestion Bug Other]
  end

  validates :feedback_type, inclusion: types_of_feedback
  validates :founder_id, presence: true

  def attachment_filename
    attachment.sanitized_file.original_filename
  end

  def self.founders_with_scores
    Founder.joins(:platform_feedback).merge(PlatformFeedback.scored).distinct
  end

  def self.promoters
    founders_with_scores.select(&:promoter?)
  end

  def self.detractors
    founders_with_scores.select(&:detractor?)
  end
end

class CoachNote < ApplicationRecord
  belongs_to :author, class_name: "User", optional: true
  belongs_to :student

  validates :note, presence: true
  validates_with RateLimitValidator,
                 limit: 100,
                 scope: :author_id,
                 time_frame: 1.hour

  scope :not_archived, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
end

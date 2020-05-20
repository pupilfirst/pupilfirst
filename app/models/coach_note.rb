class CoachNote < ApplicationRecord
  belongs_to :author, class_name: 'User', optional: true
  belongs_to :student, class_name: 'Founder'

  validates :note, presence: true

  scope :not_archived, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
end

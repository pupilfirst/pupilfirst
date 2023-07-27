class LeaderboardEntry < ApplicationRecord
  belongs_to :student

  has_one :course, through: :student

  validates :student_id, uniqueness: { scope: %i[period_from period_to] }
  validates :period_from, presence: true
  validates :period_to, presence: true
  validates :score, presence: true
end

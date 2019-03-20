class LeaderboardEntry < ApplicationRecord
  belongs_to :founder

  has_one :course, through: :founder

  validates :founder_id, uniqueness: { scope: %i[period_from period_to] }
  validates :period_from, presence: true
  validates :period_to, presence: true
  validates :score, presence: true
end

class WeeklyKarmaPoint < ApplicationRecord
  belongs_to :startup
  belongs_to :level

  validates :startup, presence: true
  validates :level, presence: true
end

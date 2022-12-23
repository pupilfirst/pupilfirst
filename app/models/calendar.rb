class Calendar < ApplicationRecord
  belongs_to :course
  has_many :calendar_events, dependent: :destroy
  has_many :calendar_cohorts, dependent: :destroy
  has_many :cohorts, through: :calendar_cohorts
end

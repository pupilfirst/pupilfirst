class TargetGroup < ApplicationRecord
  has_many :targets
  belongs_to :program_week
  has_one :batch, through: :program_week
  belongs_to :level

  validates :name, presence: true
  validates :description, presence: true
  validates :sort_index, presence: true, uniqueness: { scope: [:program_week_id] }

  scope :sorted_by_week, -> { joins(:program_week).order('program_weeks.number ASC') }

  def display_name
    "W#{program_week.number}: #{name}"
  end
end

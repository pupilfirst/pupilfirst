class TargetGroup < ApplicationRecord
  has_many :targets
  belongs_to :level
  belongs_to :track, optional: true
  has_one :school, through: :level

  validates :name, presence: true
  validates :sort_index, presence: true

  scope :sorted_by_level, -> { joins(:level).order('levels.number ASC') }

  def display_name
    "L#{level.number}: #{name}"
  end
end

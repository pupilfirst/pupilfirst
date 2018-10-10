class TargetGroup < ApplicationRecord
  has_many :targets, dependent: :restrict_with_error
  belongs_to :level
  belongs_to :track, optional: true
  has_one :school, through: :level

  validates :name, presence: true
  validates :sort_index, presence: true

  def display_name
    "#{school.short_name}##{level.number}: #{name}"
  end
end

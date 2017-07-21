class TargetGroup < ApplicationRecord
  has_many :targets
  belongs_to :level

  validates :name, presence: true
  validates :sort_index, presence: true

  scope :sorted_by_level, -> { joins(:level).order('levels.number ASC') }

  def display_name
    if level.present?
      "L#{level.number}: #{name}"
    else
      name
    end
  end
end

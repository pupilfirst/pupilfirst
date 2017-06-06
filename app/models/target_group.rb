class TargetGroup < ApplicationRecord
  has_many :targets
  belongs_to :program_week
  has_one :batch, through: :program_week
  belongs_to :level

  validates :name, presence: true
  validates :description, presence: true
  validates :sort_index, presence: true
  validates :level, presence: true

  scope :sorted_by_level, -> { joins(:level).order('levels.number ASC') }

  def display_name
    if level.present?
      "L#{level.number}: #{name}"
    elsif program_week.present?
      "W#{program_week.number}: #{name}"
    else
      name
    end
  end
end

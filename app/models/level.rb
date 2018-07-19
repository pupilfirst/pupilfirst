class Level < ApplicationRecord
  validates :number, uniqueness: { scope: :school }, presence: true
  validates :name, presence: true

  has_many :target_groups, dependent: :restrict_with_error
  has_many :startups, dependent: :restrict_with_error
  has_many :targets, through: :target_groups
  has_many :weekly_karma_points, dependent: :restrict_with_error
  has_many :resources, dependent: :restrict_with_error
  belongs_to :school

  def display_name
    "#{school.short_name}##{number}: #{name}"
  end

  def self.zero
    Level.find_by(number: 0)
  end

  def self.maximum
    order(:number).last
  end
end

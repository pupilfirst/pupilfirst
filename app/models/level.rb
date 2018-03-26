class Level < ApplicationRecord
  validates :number, uniqueness: { scope: :school }, presence: true
  validates :name, presence: true

  has_many :target_groups
  has_many :startups
  has_many :targets, through: :target_groups
  has_many :weekly_karma_points
  has_many :resources
  belongs_to :school

  def display_name
    "#{school.name} School | Level #{number}: #{name}"
  end

  def self.zero
    Level.find_by(number: 0)
  end

  def self.maximum
    order(:number).last
  end
end

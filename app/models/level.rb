class Level < ApplicationRecord
  validates :number, uniqueness: true, presence: true
  validates :name, presence: true

  has_many :target_groups
  has_many :startups
  has_many :targets, through: :target_groups

  def display_name
    "Level #{number}: #{name}"
  end

  def self.zero
    Level.find_by(number: 0)
  end
end

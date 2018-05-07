class Skill < ApplicationRecord
  has_many :target_skills, dependent: :restrict_with_error
  has_many :targets, through: :target_skills

  validates :name, presence: true
  validates :description, presence: true

  def display_name
    name
  end
end

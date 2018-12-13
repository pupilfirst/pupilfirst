class Course < ApplicationRecord
  validates :name, presence: true

  has_many :levels, dependent: :restrict_with_error
  has_many :target_groups, through: :levels
  has_many :targets, through: :target_groups

  def short_name
    name[0..2].upcase.strip
  end
end

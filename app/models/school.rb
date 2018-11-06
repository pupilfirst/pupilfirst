class School < ApplicationRecord
  validates :name, presence: true
  validates :max_grade,  numericality: { greater_than: 0 }
  validates :pass_grade, numericality: { greater_than: 0, less_than_or_equal_to: :max_grade }

  has_many :levels, dependent: :restrict_with_error
  has_many :target_groups, through: :levels
  has_many :targets, through: :target_groups
  has_many :skills, dependent: :restrict_with_error

  def short_name
    name[0..2].upcase.strip
  end

  def facebook_share_disabled?
    name.include? 'Apple'
  end
end

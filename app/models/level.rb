class Level < ApplicationRecord
  validates :number, uniqueness: { scope: :course }, presence: true
  validates :name, presence: true

  has_many :target_groups, dependent: :restrict_with_error
  has_many :startups, dependent: :restrict_with_error
  has_many :targets, through: :target_groups

  belongs_to :course

  normalize_attribute :unlock_on

  def display_name
    "#{course.short_name}##{number}: #{name}"
  end

  def short_name
    'Level ' + number.to_s
  end

  def unlocked
    !unlock_on&.future?
  end
end

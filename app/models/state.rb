class State < ApplicationRecord
  validates :name, presence: true

  has_many :colleges
  has_many :universities

  # Special states of interest for our admission campaign
  FOCUSED_FOR_ADMISSIONS = ['Kerala', 'Andhra Pradesh', 'Telangana', 'Tamil Nadu', 'Gujarat'].freeze

  scope :focused_for_admissions, -> { where(name: FOCUSED_FOR_ADMISSIONS) }

  def self.names_for_mooc_student
    ['Outside India'] + all.pluck(:name).sort
  end
end

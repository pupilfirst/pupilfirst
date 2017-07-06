class State < ApplicationRecord
  validates :name, presence: true

  has_many :colleges
  has_many :replacement_universities
  has_many :batch_applicants, through: :colleges
  has_many :batch_applications, through: :batch_applicants

  # Special states of interest for our admission campaign
  FOCUSED_FOR_ADMISSIONS = ['Kerala', 'Andhra Pradesh', 'Telangana', 'Tamil Nadu', 'Gujarat'].freeze

  scope :focused_for_admissions, -> { where(name: FOCUSED_FOR_ADMISSIONS) }

  def self.names_for_mooc_student
    ['Outside India'] + all.pluck(:name).sort
  end
end

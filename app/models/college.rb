class College < ApplicationRecord
  validates :name, presence: true

  belongs_to :state
  belongs_to :replacement_university
  has_many :batch_applicants
  has_many :founders, dependent: :restrict_with_error
end

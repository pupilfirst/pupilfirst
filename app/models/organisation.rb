class Organisation < ApplicationRecord
  belongs_to :school
  has_many :users, dependent: :restrict_with_error
  has_many :students, through: :users
  has_many :cohorts, through: :students
  has_many :organisation_admins, dependent: :restrict_with_error
end

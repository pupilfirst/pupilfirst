class Organisation < ApplicationRecord
  belongs_to :school
  has_many :users, dependent: :restrict_with_error
  has_many :founders, through: :users
  has_many :cohorts, through: :founders
  has_many :organisation_admins, dependent: :restrict_with_error
end

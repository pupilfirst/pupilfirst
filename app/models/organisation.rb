class Organisation < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :organisation_admin, dependent: :restrict_with_error
end

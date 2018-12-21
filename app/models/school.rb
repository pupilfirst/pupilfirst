class School < ApplicationRecord
  has_many :courses, dependent: :restrict_with_error

  validates :subdomain, presence: true
end

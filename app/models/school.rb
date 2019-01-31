class School < ApplicationRecord
  has_many :courses, dependent: :restrict_with_error
  has_many :domains, dependent: :destroy
  has_many :faculty, dependent: :destroy
end

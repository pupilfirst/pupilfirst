class School < ApplicationRecord
  has_many :courses, dependent: :restrict_with_error
  has_many :faculty, dependent: :restrict_with_error
end

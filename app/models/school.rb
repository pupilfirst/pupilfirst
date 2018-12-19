class School < ApplicationRecord
  has_many :courses, dependent: :restrict_with_error
end

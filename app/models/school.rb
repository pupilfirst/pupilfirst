class School < ApplicationRecord
  validates :name, presence: true

  has_many :levels, dependent: :restrict_with_error
end

class State < ApplicationRecord
  validates :name, presence: true

  has_many :colleges, dependent: :restrict_with_error
  has_many :universities, dependent: :restrict_with_error
end

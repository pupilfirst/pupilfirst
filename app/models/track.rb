class Track < ApplicationRecord
  has_many :target_groups, dependent: :restrict_with_error

  validates :sort_index, numericality: true
end

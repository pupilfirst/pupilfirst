class Track < ApplicationRecord
  has_many :target_groups

  validates :sort_index, numericality: true
end

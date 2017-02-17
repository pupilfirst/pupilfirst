class Level < ApplicationRecord
  validates :number, uniqueness: true, presence: true
  validates :name, presence: true

  has_many :target_groups
end

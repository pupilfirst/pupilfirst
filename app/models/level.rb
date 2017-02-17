class Level < ApplicationRecord
  validates :number, uniqueness: true, presence: true
  validates :name, presence: true
end

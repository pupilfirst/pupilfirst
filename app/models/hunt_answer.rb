class HuntAnswer < ApplicationRecord
  validates :answer, presence: true
  validates :stage, presence: true, numericality: { greater_than_or_equal_to: 1 }, uniqueness: true
end

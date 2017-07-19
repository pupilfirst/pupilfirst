class College < ApplicationRecord
  belongs_to :state
  belongs_to :university
  has_many :founders, dependent: :restrict_with_error

  validates :name, presence: true
end

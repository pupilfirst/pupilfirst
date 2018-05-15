class University < ApplicationRecord
  validates :name, presence: true

  belongs_to :state
  has_many :colleges, dependent: :restrict_with_error
  has_many :founders, through: :colleges
end

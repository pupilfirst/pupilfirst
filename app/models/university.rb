class University < ApplicationRecord
  validates :name, presence: true

  belongs_to :state
  has_many :colleges
  has_many :founders, through: :colleges
end

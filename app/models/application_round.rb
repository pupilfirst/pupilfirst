class ApplicationRound < ApplicationRecord
  belongs_to :batch
  has_many :round_stages, dependent: :destroy
  has_many :batch_applications, dependent: :restrict_with_error

  validates :batch, presence: true
  validates :number, presence: true

  accepts_nested_attributes_for :round_stages, allow_destroy: true
end

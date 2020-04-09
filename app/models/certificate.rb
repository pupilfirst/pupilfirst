class Certificate < ApplicationRecord
  belongs_to :course

  has_many :issued_certificates, dependent: :restrict_with_error

  scope :active, -> { where(active: true) }

  has_one_attached :image
end

class IssuedCertificate < ApplicationRecord
  belongs_to :certificate
  has_one :course, through: :certificate
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :serial_number, presence: true, uniqueness: true
end

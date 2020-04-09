class IssuedCertificate < ApplicationRecord
  belongs_to :certificate
  belongs_to :user

  validates :name, presence: true
  validates :serial_number, presence: true
end

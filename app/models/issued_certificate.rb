class IssuedCertificate < ApplicationRecord
  belongs_to :certificate
  has_one :course, through: :certificate
  belongs_to :user, optional: true
  belongs_to :issuer, class_name: 'User', optional: true
  belongs_to :revoker, class_name: 'User', optional: true

  validates :name, presence: true
  validates :serial_number, presence: true, uniqueness: true

  scope :live, -> { where(revoked_at: nil) }
end

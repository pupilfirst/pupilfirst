class Applicant < ApplicationRecord
  belongs_to :course

  has_secure_token :login_token

  validates :name, presence: true
  validates :email, presence: true, email: true
  validates :email, uniqueness: { scope: :course_id }

  scope :with_email, ->(email) { where('lower(email) = ?', email.downcase) }
end

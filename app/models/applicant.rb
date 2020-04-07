class Applicant < ApplicationRecord
  belongs_to :course

  has_secure_token :login_token

  acts_as_taggable

  validates :name, presence: true
  validates :email, presence: true, email: true, uniqueness: { scope: :course_id }

  scope :with_email, ->(email) { where('lower(email) = ?', email.downcase) }
end

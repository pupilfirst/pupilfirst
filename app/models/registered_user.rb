class RegisteredUser < ApplicationRecord
  belongs_to :course

  validates :email, presence: true, email: true
  validates :email, uniqueness: { scope: :course_id }

  has_secure_token :login_token
end

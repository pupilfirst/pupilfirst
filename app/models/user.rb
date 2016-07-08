class User < ActiveRecord::Base
  has_one :mooc_student, dependent: :restrict_with_error

  has_secure_token :login_token
  after_create :regenerate_login_token

  validates :email, uniqueness: true, format: { with: /@/, message: 'does not look like a valid address!' }
end

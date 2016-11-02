class User < ApplicationRecord
  has_one :mooc_student, dependent: :restrict_with_error
  has_one :founder, dependent: :restrict_with_error

  has_secure_token :login_token

  # database_authenticable is required by devise_for to generate the session routes
  devise :database_authenticatable, :trackable, :rememberable

  validates :email, presence: true, uniqueness: true, email: true
end

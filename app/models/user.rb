class User < ApplicationRecord
  has_one :mooc_student, dependent: :restrict_with_error
  has_one :founder, dependent: :restrict_with_error
  has_one :batch_applicant, dependent: :restrict_with_error
  has_one :admin_user, dependent: :restrict_with_error
  has_many :user_activities
  has_many :visits, as: :user

  has_secure_token :login_token

  # database_authenticable is required by devise_for to generate the session routes
  devise :database_authenticatable, :trackable, :rememberable, :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :github]

  validates :email, presence: true, uniqueness: true, email: true

  scope :with_email, -> (email) { where('lower(email) = ?', email.downcase) }

  def email_bounced?
    email_bounced_at.present?
  end
end

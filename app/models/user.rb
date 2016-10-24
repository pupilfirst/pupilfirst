class User < ApplicationRecord
  has_one :mooc_student, dependent: :restrict_with_error

  has_secure_token :login_token

  def send_login_email(referer)
    regenerate_login_token unless Rails.env.development?

    # TODO: Send email with template.
    UserSessionMailer.send_login_token(self, referer).deliver_now
  end

  validates :email, presence: true, uniqueness: true, email: true
end

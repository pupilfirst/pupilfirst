# This module is included in UserSignInForm.
module EmailBounceValidatable
  extend ActiveSupport::Concern

  included do
    validate :email_should_not_have_bounced
  end

  def email_should_not_have_bounced
    return if email.blank?

    user = User.with_email(email)
    return unless user&.email_bounced?

    errors[:base] << "The email address you supplied cannot be used because an email we'd sent earlier bounced."
    errors[:email] << 'is an address which bounced'
  end
end

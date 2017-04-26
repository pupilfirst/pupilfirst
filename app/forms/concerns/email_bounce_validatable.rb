# This module is included in UserSignInForm and Founders::RegistrationForm.
module EmailBounceValidatable
  extend ActiveSupport::Concern

  included do
    validate :email_should_not_have_bounced
  end

  def email_should_not_have_bounced
    return if email.blank?
    user = User.with_email(email)
    return unless user&.email_bounced?
    errors[:base] << 'The email address you supplied cannot be used because an email we sent bounced. Please contact help@sv.co for more information.'
    errors[:email] << 'is an address which bounced'
  end
end

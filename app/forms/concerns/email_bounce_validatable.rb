# This module is included in BatchApplications::RegistrationForm and UserSignInForm
module EmailBounceValidatable
  extend ActiveSupport::Concern

  included do
    validate :email_should_not_have_bounced
  end

  def email_should_not_have_bounced
    user = email.present? ? User.with_email(email).first : nil
    return unless user&.email_bounced?
    errors[:base] << 'The email address you supplied cannot be used because an email we sent bounced. Please contact help@sv.co for more information.'
    errors[:email] << 'is an address which bounced'
  end
end

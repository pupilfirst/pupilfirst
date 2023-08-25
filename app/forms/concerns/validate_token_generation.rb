# This module is included in:
#   Users::Sessions::SendResetPasswordEmailForm
#   Users::Sessions::SignInWithEmailForm

module ValidateTokenGeneration
  extend ActiveSupport::Concern

  attr_accessor :current_school

  private

  def duplicate_request?
    return false if token_generated_at.blank?

    time_since_last_mail = Time.zone.now - token_generated_at

    time_since_last_mail < 2.minutes
  end

  def email_should_not_have_bounced
    return if email.blank?

    return unless user&.email_bounced?

    errors.add(
      :email,
      "The email address you supplied cannot be used because an email we sent earlier bounced"
    )
  end

  def user
    @user ||=
      begin
        current_school.users.with_email(email).first if email.present?
      end
  end
end

# This module is included in:
#   Users::Sessions::SendResetPasswordEmailForm
#   Users::Sessions::SignInWithEmailForm
#

module ValidateTokenGeneration
  extend ActiveSupport::Concern

  attr_accessor :current_school

  private

  def user_with_email_must_exist
    return if user.present? || email.blank?

    errors.add(:base, I18n.t('shared.no_email_found'))
  end

  def ensure_time_between_requests
    return if user.blank?

    return if token_generated_at.blank?

    time_since_last_mail = Time.zone.now - token_generated_at

    return if time_since_last_mail > 2.minutes

    errors.add(
      :base,
      'An email was sent less than two minutes ago. Please wait for a few minutes before trying again.'
    )
  end

  def email_should_not_have_bounced
    return if email.blank?

    return unless user&.email_bounced?

    errors.add(
      :email,
      'The email address you supplied cannot be used because an email we sent earlier bounced'
    )
  end

  def user
    @user ||=
      begin
        current_school.users.with_email(email).first if email.present?
      end
  end
end

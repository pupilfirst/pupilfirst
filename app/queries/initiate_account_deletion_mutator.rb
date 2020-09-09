class InitiateAccountDeletionMutator < ApplicationQuery
  property :email, validates: { presence: true }

  validate :user_must_not_be_admin
  validate :ensure_time_between_requests

  def execute
    Users::MailAccountDeletionTokenService.new(current_user).execute
  end

  private

  def authorized?
    current_user.present? && current_user.email == email
  end

  def user_must_not_be_admin
    return if current_school_admin.blank?

    errors[:base] << 'You are an admin; please delete your admin access before retrying'
  end

  def ensure_time_between_requests
    return if current_user.delete_account_sent_at.blank?

    time_since_last_mail = Time.zone.now - current_user.delete_account_sent_at

    return if time_since_last_mail > 30.minutes

    errors[:base] << 'An email was sent already with a valid link to delete account. Please check your inbox'
  end
end

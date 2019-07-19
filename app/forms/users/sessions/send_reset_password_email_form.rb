module Users
  module Sessions
    class SendResetPasswordEmailForm < Reform::Form
      attr_accessor :current_school

      property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
      # Honeypot field. See validation `detect_honeypot` below.
      property :username

      validate :user_with_email_must_exist
      validate :ensure_time_between_requests
      validate :detect_honeypot
      validate :email_should_not_have_bounced

      def save(current_domain)
        Users::MailResetPasswordTokenService.new(current_school, current_domain, user).execute
      end

      private

      def user_with_email_must_exist
        return if user.present? || email.blank?

        errors[:base] << 'Could not find user with this email. Please check the email that you entered.'
      end

      def ensure_time_between_requests
        return if user.blank?
        return if user.reset_password_sent_at.blank?

        time_since_last_mail = Time.zone.now - user.reset_password_sent_at
        return if time_since_last_mail > 2.minutes

        errors[:base] << 'An email was sent less than two minutes ago. Please wait for a few minutes before trying again.'
      end

      def detect_honeypot
        return if username.blank?

        errors[:base] << 'Your request has been blocked because it is suspicious.'
      end

      def email_should_not_have_bounced
        return if email.blank?

        return unless user&.email_bounced?

        errors[:email] << "The email address you supplied cannot be used because an email we'd sent earlier bounced"
      end

      def user
        @user ||= begin
          current_school.users.with_email(email).first if email.present?
        end
      end

      def shared_device?
        shared_device == '1'
      end
    end
  end
end

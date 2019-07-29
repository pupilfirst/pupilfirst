module Users
  module Sessions
    class SendResetPasswordEmailForm < Reform::Form
      include ValidateTokenGeneration

      validate :user_with_email_must_exist
      validate :ensure_time_between_requests
      validate :detect_honeypot
      validate :email_should_not_have_bounced

      property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
      # Honeypot field. See validation `detect_honeypot` below.
      property :username

      def save
        Users::MailResetPasswordTokenService.new(current_school, user).execute
      end

      private

      def token_generated_at
        user&.reset_password_sent_at
      end
    end
  end
end

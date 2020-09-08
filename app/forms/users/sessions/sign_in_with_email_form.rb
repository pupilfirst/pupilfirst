module Users
  module Sessions
    class SignInWithEmailForm < Reform::Form
      include ValidateTokenGeneration

      property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
      # Honeypot field. See validation `detect_honeypot` below.
      property :username
      property :referrer
      property :shared_device

      validate :user_with_email_must_exist
      validate :ensure_time_between_requests
      validate :detect_honeypot
      validate :email_should_not_have_bounced

      def save
        MailLoginTokenService.new(user, referrer, shared_device?).execute
      end

      private

      def token_generated_at
        user&.login_mail_sent_at
      end

      def shared_device?
        shared_device == '1'
      end
    end
  end
end

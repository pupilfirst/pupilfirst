module Users
  module Sessions
    class SendResetPasswordEmailForm < Reform::Form
      include ValidateTokenGeneration

      validate :email_should_not_have_bounced

      property :email,
               validates: {
                 presence: true,
                 length: {
                   maximum: 250
                 },
                 email: true
               }

      def save
        return if user.blank? || duplicate_request?

        Users::MailResetPasswordTokenService.new(current_school, user).execute
      end

      private

      def token_generated_at
        user&.reset_password_sent_at
      end
    end
  end
end

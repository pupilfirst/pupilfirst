module Users
  module Sessions
    class SignInWithEmailForm < Reform::Form
      include ValidateTokenGeneration

      property :email,
               validates: {
                 presence: true,
                 length: {
                   maximum: 250
                 },
                 email: true
               }
      property :referrer
      property :shared_device

      validate :email_should_not_have_bounced

      def save
        return if user.blank? || duplicate_request?

        MailLoginTokenService.new(user, referrer, shared_device?).execute
      end

      private

      def token_generated_at
        user&.login_token_generated_at
      end

      def shared_device?
        shared_device == "1"
      end
    end
  end
end

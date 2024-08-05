module Users
  module Sessions
    class SignInWithInputTokenForm < Reform::Form
      attr_accessor :current_school
      attr_reader :input_tokens_deleted

      property :email,
               validates: {
                 presence: true,
                 length: {
                   maximum: 250
                 },
                 email: true
               }

      property :input_token, validates: { presence: true }
      property :shared_device

      validate :check_token

      def user
        @user ||= current_school.users.with_email(email).first
      end

      def shared_device?
        shared_device == "1"
      end

      private

      def check_token
        if user.blank?
          add_token_mismatch_error
          return
        end

        result =
          AuthenticationToken.verify_token(
            input_token,
            authenticatable: user,
            purpose: "sign_in"
          )

        case result
        when :valid
          # Do nothing
        when :invalid
          add_token_mismatch_error
        when :input_tokens_deleted
          errors.add(
            :base,
            I18n.t(
              "users.sessions.sign_in_with_input_token_form.input_tokens_deleted"
            )
          )

          @input_tokens_deleted = true
        else
          raise "Unexpected result from AuthenticationToken.verify_token: #{result}"
        end
      end

      def add_token_mismatch_error
        errors.add(
          :base,
          I18n.t("users.sessions.sign_in_with_input_token_form.token_mismatch")
        )
      end
    end
  end
end

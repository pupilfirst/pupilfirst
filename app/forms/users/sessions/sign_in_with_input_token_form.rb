module Users
  module Sessions
    class SignInWithInputTokenForm < Reform::Form
      attr_accessor :current_school

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
        @user ||=
          begin
            current_school.users.with_email(email).first if email.present?
          end
      end

      def shared_device?
        shared_device == "1"
      end

      private

      def check_token
        if AuthenticationToken.verify_token(
             input_token,
             authenticatable: user,
             purpose: "sign_in"
           )
          return
        end

        errors.add(
          :base,
          I18n.t("users.sessions.sign_in_with_input_token_form.token_mismatch")
        )
      end
    end
  end
end

module Users
  module Sessions
    class ResetPasswordForm < Reform::Form
      property :token, validates: { presence: true }
      property :new_password, validates: { presence: true, length: { minimum: 8, maximum: 128 } }
      property :confirm_password, validates: { presence: true }

      validate :password_should_match
      validate :user_must_exist

      def save
        @user.update!(password: new_password, reset_password_token: nil)
      end

      def user
        @user ||= User.find_by(reset_password_token: token)
      end

      private

      def user_must_exist
        return if user.present?

        errors[:base] << "Your token doesn't appear to be valid. Please refresh the page and try again."
      end

      def password_should_match
        return if new_password == confirm_password

        errors[:base] << 'Your password and confirmation password do not match. Please try again.'
      end
    end
  end
end

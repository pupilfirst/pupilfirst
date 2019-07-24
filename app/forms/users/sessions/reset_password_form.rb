module Users
  module Sessions
    class ResetPasswordForm < Reform::Form
      property :token, validates: { presence: true }
      property :new_password, validates: { presence: true }
      property :confirm_password, validates: { presence: true }

      validate :password_should_match
      validate :should_have_valid_length
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

        errors[:base] << 'Invalid user, Please refresh the page and try again'
      end

      def password_should_match
        return if new_password == confirm_password

        errors[:base] << 'Your password and confirmation password do not match. Please try again.'
      end

      def should_have_valid_length
        return if new_password.blank?

        password_length = new_password.length

        return if password_length >= 8 && password_length < 128

        errors[:base] << 'Supplied password must be between 8 and 128 characters in length'
      end
    end
  end
end

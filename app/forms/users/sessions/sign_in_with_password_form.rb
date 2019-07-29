module Users
  module Sessions
    class SignInWithPasswordForm < Reform::Form
      attr_accessor :current_school

      property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
      property :password, validates: { presence: true }
      property :shared_device

      validate :user_with_email_must_exist
      validate :must_have_valid_password

      def user
        @user ||= begin
          current_school.users.with_email(email).first if email.present?
        end
      end

      def shared_device?
        shared_device == '1'
      end

      private

      def user_with_email_must_exist
        return if user.present? || email.blank?

        errors[:base] << 'Could not find user with this email. Please check the email that you entered.'
      end

      def must_have_valid_password
        return if user.blank?

        return if user.valid_password?(password)

        errors[:base] << 'The supplied password is incorrect. Please check and try again.'
      end
    end
  end
end

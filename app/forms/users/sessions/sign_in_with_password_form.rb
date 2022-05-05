module Users
  module Sessions
    class SignInWithPasswordForm < Reform::Form
      attr_accessor :current_school

      property :email, validates: { presence: true, length: { maximum: 250 }, email: true }
      property :password, validates: { presence: true }
      property :shared_device

      validate :check_credentials

      def user
        @user ||= begin
          current_school.users.with_email(email).first if email.present?
        end
      end

      def shared_device?
        shared_device == '1'
      end

      private

      def check_credentials
        return if user&.valid_password?(password)

        errors[:base] << I18n.t('sessions.create.invalid_credentials')
      end
    end
  end
end

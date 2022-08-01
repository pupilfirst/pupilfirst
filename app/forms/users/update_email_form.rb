module Users
  class UpdateEmailForm < Reform::Form
    property :token, validates: { presence: true }
    validate :user_must_exist

    def save
      @user.update!(email: new_email, update_email_token: nil)
    end

    def user
      update_email_token = Digest::SHA2.base64digest(token)
      @user ||= User.find_by(update_email_token: update_email_token)
    end

    private

    def user_must_exist
      return if user.present?

      errors.add(
        :token,
        "doesn't appear to be valid. Please refresh the page and try again."
      )
    end
  end
end

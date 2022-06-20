module Users
  class SendUpdateEmailForm < Reform::Form
    attr_accessor :current_user

    include ValidateTokenGeneration
    validate :user_with_email_must_exist
    validate :ensure_time_between_requests
    validate :new_email_is_unique

    property :new_email,
             validates: {
               presence: true,
               length: {
                 maximum: 250
               },
               email: true
             },
             virtual: true
    property :email,
             validates: {
               presence: true,
               length: {
                 maximum: 250
               },
               email: true
             }

    def save
      Users::MailUpdateEmailTokenService.new(
        current_school,
        current_user,
        new_email
      ).execute
    end

    private

    def token_generated_at
      user&.update_email_token_sent_at
    end

    def new_email_is_unique
      user_with_new_email = User.find_by(email: new_email)
      if user_with_new_email.present? || new_email.blank? ||
           new_email == current_user.email
        errors.add(:new_email, 'already exists')
      end
    end
  end
end

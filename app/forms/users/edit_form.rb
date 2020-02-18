module Users
  class EditForm < Reform::Form
    property :name, validates: { presence: true }
    property :phone, validates: { mobile_number: true, allow_blank: true }
    property :avatar, virtual: true, validates: { image: true, file_size: { less_than: 5.megabytes } }
    property :about, validates: { length: { maximum: 1000 } }
    property :skype_id
    property :communication_address, validates: { length: { maximum: 250 }, allow_blank: true }
    property :twitter_url, validates: { url: true, allow_blank: true }
    property :linkedin_url, validates: { url: true, allow_blank: true }
    property :personal_website_url, validates: { url: true, allow_blank: true }
    property :blog_url, validates: { url: true, allow_blank: true }
    property :angel_co_url, validates: { url: true, allow_blank: true }
    property :github_url, validates: { url: true, allow_blank: true }
    property :behance_url, validates: { url: true, allow_blank: true }
    property :daily_digest, validates: { presence: true }, virtual: true
    property :current_password, virtual: true
    property :new_password, virtual: true
    property :new_password_confirmation, virtual: true

    validate :current_password_should_be_valid
    validate :new_passwords_should_match
    validate :passwords_should_be_secure

    def save!
      User.transaction do
        model.update!(user_params)

        if new_password.present?
          model.password = new_password
          model.password_confirmation = new_password_confirmation
          model.save!
        end

        model.avatar.attach(avatar) if avatar.present?
      end
    end

    def user_params
      {
        name: name,
        phone: phone,
        about: about,
        skype_id: skype_id,
        communication_address: communication_address,
        twitter_url: twitter_url,
        linkedin_url: linkedin_url,
        personal_website_url: personal_website_url,
        blog_url: blog_url,
        angel_co_url: angel_co_url,
        github_url: github_url,
        behance_url: behance_url,
        preferences: {
          daily_digest: daily_digest == "1"
        }
      }
    end

    private

    def current_password_should_be_valid
      return if new_password.blank? || model.encrypted_password.blank? || model.valid_password?(current_password)

      errors[:current_password] << 'is incorrect'
    end

    def new_passwords_should_match
      return if new_password == new_password_confirmation

      errors[:new_password_confirmation] << 'does not match'
    end

    def passwords_should_be_secure
      return if new_password.blank? || new_password.length >= 8

      errors[:new_password] << 'should be at least 8 characters long'
    end
  end
end

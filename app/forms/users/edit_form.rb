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

    def save!
      User.transaction do
        model.update!(user_params)
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
        behance_url: behance_url
      }
    end
  end
end

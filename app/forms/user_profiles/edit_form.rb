module UserProfiles
  class EditForm < Reform::Form
    property :name, validates: { presence: true }
    property :phone, validates: { presence: true, mobile_number: true }
    property :avatar, virtual: true, validates: { file_content_type: { allow: ['image/jpeg', 'image/png'] }, file_size: { less_than: 2.gigabytes } }
    property :about, validates: { length: { maximum: 1000 } }
    # property :roles
    property :skype_id
    property :communication_address, validates: { presence: true, length: { maximum: 250 } }
    property :twitter_url, validates: { url: true, allow_blank: true }
    property :linkedin_url, validates: { url: true, allow_blank: true }
    property :personal_website_url, validates: { url: true, allow_blank: true }
    property :blog_url, validates: { url: true, allow_blank: true }
    property :angel_co_url, validates: { url: true, allow_blank: true }
    property :github_url, validates: { url: true, allow_blank: true }
    property :behance_url, validates: { url: true, allow_blank: true }

    def save!
      UserProfile.transaction do
        model.update!(user_profile_params)
        model.avatar.attach(avatar) if avatar.present?
      end
    end

    def user_profile_params
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

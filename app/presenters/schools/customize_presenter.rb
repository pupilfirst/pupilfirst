module Schools
  class CustomizePresenter < ApplicationPresenter
    def json_props
      {
        authenticityToken: view.form_authenticity_token,
        customizations: {
          strings: school_strings,
          images: school_images,
          links: school_links
        },
        schoolName: current_school.name,
        schoolAbout: current_school.about
      }.to_json
    end

    def school_images
      {
        logoOnLightBg: image_details(current_school.logo_on_light_bg),
        icon: current_school.icon.attached? ? file_details(current_school.icon) : { url: '/favicon.png', filename: 'pupilfirst_icon.png' },
        coverImage: image_details(current_school.cover_image)
      }
    end

    private

    def school_strings
      {
        address: SchoolString::Address.for(current_school),
        emailAddress: SchoolString::EmailAddress.for(current_school),
        privacyPolicy: SchoolString::PrivacyPolicy.for(current_school),
        termsAndConditions: SchoolString::TermsAndConditions.for(current_school)
      }
    end

    def image_details(image)
      image.attached? ? file_details(image) : nil
    end

    def file_details(file)
      {
        url: view.url_for(file),
        filename: file.filename
      }
    end

    def school_links
      current_school.school_links.as_json(only: %i[kind id title url]).map do |link|
        link['id'] = link['id'].to_s
        link
      end
    end
  end
end

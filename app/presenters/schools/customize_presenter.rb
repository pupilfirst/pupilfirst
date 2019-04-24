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
        schoolName: current_school.name
      }.to_json
    end

    def school_images
      {
        logoOnLightBg: current_school.logo_on_light_bg.attached? ? file_details(current_school.logo_on_light_bg) : nil,
        logoOnDarkBg: current_school.logo_on_dark_bg.attached? ? file_details(current_school.logo_on_dark_bg) : nil,
        icon: current_school.icon.attached? ? file_details(current_school.icon) : { url: view.image_path('layouts/shared/favicon.png'), filename: 'pupilfirst_icon.png' }
      }
    end

    private

    def school_strings
      {
        address: SchoolString::Address.for(current_school),
        emailAddress: SchoolString::EmailAddress.for(current_school),
        privacyPolicy: SchoolString::PrivacyPolicy.for(current_school),
        termsOfUse: SchoolString::TermsOfUse.for(current_school)
      }
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

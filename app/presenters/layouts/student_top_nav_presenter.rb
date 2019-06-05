module Layouts
  class StudentTopNavPresenter < ::ApplicationPresenter
    def props
      {
        school_name: school_name,
        logo_url: logo_url,
        links: nav_links
      }
    end

    def school_name
      @school_name ||= current_school.present? ? current_school.name : 'PupilFirst'
    end

    def logo_url
      if current_school.blank?
        view.image_url('mailer/pupilfirst-logo.png')
      elsif current_school.logo_on_light_bg.attached?
        view.url_for(current_school.logo_variant(:mid))
      end
    end

    private

    def nav_links
      @nav_links ||= begin
        # Admin link
        links = [admin_link] - [nil]

        # ...and the custom links.
        custom_links = SchoolLink.where(school: current_school, kind: SchoolLink::KIND_HEADER).order(created_at: :DESC).map do |school_link|
          { title: school_link.title, url: school_link.url }
        end

        # Both, with the user-based links at the front.
        links + home_link + custom_links
      end
    end

    def admin_link
      { title: 'Admin', url: '/school' } if current_school.present? && view.policy(current_school).show?
    end

    def home_link
      [{ title: 'Home', url: '/home' }]
    end
  end
end

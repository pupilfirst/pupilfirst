module Layouts
  class StudentTopNavPresenter < ::ApplicationPresenter
    def school_name
      @school_name ||= current_school.present? ? current_school.name : 'PupilFirst'
    end

    def logo?
      return true if current_school.blank?

      current_school.logo_on_light_bg.attached?
    end

    def logo_url
      if current_school.blank?
        view.image_url('mailer/pupilfirst-logo.png')
      else
        view.url_for(current_school.logo_variant(:mid))
      end
    end

    def visible_links
      if nav_links.length > 4
        nav_links[0..2]
      else
        nav_links
      end
    end

    def more_links
      @more_links ||= begin
        if nav_links.length > 4
          {
            title: 'More',
            id: 'navbar-more-dropdown',
            options: nav_links[-(nav_links.length - 3)..-1]
          }
        end
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
        links + custom_links
      end
    end

    def admin_link
      { title: 'Admin', url: '/school' } if current_school.present? && view.policy(current_school).show?
    end
  end
end

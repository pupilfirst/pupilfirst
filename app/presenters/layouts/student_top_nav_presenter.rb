module Layouts
  class StudentTopNavPresenter < ::ApplicationPresenter
    def props
      {
        school_name: school_name,
        logo_url: logo_url,
        links: nav_links,
        authenticity_token: view.form_authenticity_token,
        is_logged_in: current_user.present?
      }
    end

    def school_name
      @school_name ||= current_school.present? ? current_school.name : 'Pupilfirst'
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
        # ...and the custom links.
        custom_links = SchoolLink.where(school: current_school, kind: SchoolLink::KIND_HEADER).order(created_at: :DESC).map do |school_link|
          { title: school_link.title, url: school_link.url }
        end

        # Both, with the user-based links at the front.
        admin_link + home_link + custom_links
      end
    end

    def admin_link
      if current_school.present? && view.policy(current_school).show?
        [{ title: 'Admin', url: view.school_path }]
      elsif current_user.present? && course_authors.any?
        [{ title: 'Admin', url: view.curriculum_school_course_path(course_authors.first.course) }]
      else
        []
      end
    end

    def home_link
      if current_user.present?
        [{ title: 'Home', url: '/home' }]
      else
        []
      end
    end

    def course_authors
      @course_authors ||= current_user.course_authors.where(course: current_school.courses)
    end
  end
end

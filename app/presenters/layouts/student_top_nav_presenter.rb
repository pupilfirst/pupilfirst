module Layouts
  class StudentTopNavPresenter < ::ApplicationPresenter
    def props
      {
        school_name: school_name,
        logo_url: logo_url,
        links: nav_links,
        authenticity_token: view.form_authenticity_token,
        is_logged_in: current_user.present?,
        current_user: user_details,
        has_notifications: notifications?
      }
    end

    def school_name
      @school_name ||= current_school.present? ? current_school.name : 'Pupilfirst'
    end

    def logo_url
      if current_school.blank?
        view.image_url('mailer/pupilfirst-logo.png')
      elsif current_school.logo_on_light_bg.attached?
        view.url_for(current_school.logo_variant(:high))
      end
    end

    private

    def notifications?
      return false if current_user.blank?

      current_user.notifications.where(read_at: nil).any?
    end

    def nav_links
      @nav_links ||= begin
        # ...and the custom links.
        custom_links = SchoolLink.where(school: current_school, kind: SchoolLink::KIND_HEADER).order(created_at: :DESC).map do |school_link|
          { title: school_link.title, url: school_link.url }
        end

        # Both, with the user-based links at the front.
        admin_link + dashboard_link + coaches_link + custom_links
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

    def dashboard_link
      if current_user.present?
        [{ title: 'Dashboard', url: '/dashboard' }]
      else
        []
      end
    end

    def course_authors
      @course_authors ||= current_user.course_authors.where(course: current_school.courses)
    end

    def user_details
      return if current_user.blank?
      {
        id: current_user.id,
        name: current_user.name,
        title: current_user.title,
        avatar_url: current_user.avatar_url(variant: :thumb)
      }
    end

    def coaches_link
      if current_school.users.joins(:faculty).exists?(faculty: { public: true })
        [{ title: 'Coaches', url: '/coaches' }]
      else
        []
      end
    end
  end
end

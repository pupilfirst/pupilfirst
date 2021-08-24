module Layouts
  class SchoolPresenter < ::ApplicationPresenter
    def props
      {
        school_name: current_school.name,
        school_logo_path: school_logo_path,
        school_icon_path: school_icon_path,
        courses: courses,
        is_course_author: current_user_is_a_course_author?,
        has_notifications: notifications?
      }
    end

    private

    def notifications?
      return false if current_user.blank?

      current_user.notifications.unread.any?
    end

    def school_logo_path
      if current_school.logo_on_light_bg.attached?
        view.rails_public_blob_url(current_school.logo_variant('thumb'))
      else
        view.image_path('shared/pupilfirst-logo.svg')
      end
    end

    def school_icon_path
      if current_school.icon.attached?
        view.rails_public_blob_url(current_school.icon_variant('thumb'))
      else
        '/favicon.png'
      end
    end

    def courses
      if current_user.school_admin.present?
        current_school.courses.live.as_json(only: %i[name id ends_at])
      elsif current_user.course_authors.any?
        current_school
          .courses
          .live
          .where(id: current_user.course_authors.pluck(:course_id))
          .as_json(only: %i[name id ends_at])
      end
    end

    def current_user_is_a_course_author?
      current_user.course_authors.exists?(course: current_school.courses) &&
        current_user.school_admin.blank?
    end
  end
end

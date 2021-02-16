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

      current_user.notifications.where(read_at: nil).any?
    end

    def school_logo_path
      if current_school.logo_on_light_bg.attached?
        view.rails_blob_path(current_school.logo_variant("thumb"), only_path: true)
      else
        view.image_path('shared/pupilfirst-logo.svg')
      end
    end

    def school_icon_path
      if current_school.icon.attached?
        view.rails_blob_path(current_school.icon_variant("thumb"), only_path: true)
      else
        '/favicon.png'
      end
    end

    def courses
      if current_user.school_admin.present?
        current_school.courses.as_json(only: %i[name id])
      elsif current_user.course_authors.any?
        current_school.courses.where(id: current_user.course_authors.pluck(:course_id)).as_json(only: %i[name id])
      end
    end

    def current_user_is_a_course_author?
      current_user.course_authors.exists?(course: current_school.courses) && current_user.school_admin.blank?
    end
  end
end

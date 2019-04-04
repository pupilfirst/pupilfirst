module Layouts
  class SchoolPresenter < ::ApplicationPresenter
    def coach_profile?
      coach_dashboard_path.present?
    end

    def founder_profile?
      current_user.founders.joins(:school).where(schools: { id: current_school }).exists?
    end

    def coach_dashboard_path
      @coach_dashboard_path ||= begin
        faculty = current_user.faculty.find_by(school: current_school)

        if faculty.present?
          if faculty.courses.exists?
            view.course_coach_dashboard_path(faculty.courses.first)
          elsif faculty.startups.exists?
            view.course_coach_dashboard_path(faculty.startups.first.course)
          end
        end
      end
    end

    def school_logo_path
      if current_school.logo_on_light_bg.attached?
        current_school.logo_variant("thumb")
      else
        'shared/pupilfirst-icon.svg'
      end
    end

    def nav_link_classes(path)
      default_classes = "global-sidebar__primary-nav-link py-4 px-5"
      view.current_page?(path) ? default_classes + " global-sidebar__primary-nav-link--active" : default_classes
    end
  end
end

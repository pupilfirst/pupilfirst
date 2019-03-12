module Layouts
  class SchoolPresenter < ::ApplicationPresenter
    def coach_profile?
      current_user.faculty.joins(:school).where(schools: { id: current_school }).exists?
    end

    def founder_profile?
      current_user.founders.joins(:school).where(schools: { id: current_school }).exists?
    end

    def coach_dashboard
      view.course_coach_dashboard_path(current_user.faculty.first.courses.first)
    end

    def school_logo_path
      current_school.logo_variant("mid") || 'shared/pupilfirst-logo-white.svg'
    end
  end
end

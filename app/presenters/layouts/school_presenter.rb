module Layouts
  class SchoolPresenter < ::ApplicationPresenter
    def coach_profile?
      current_user.faculty.joins(:school).where(schools: { id: current_school }).exists?
    end

    def founder_profile?
      current_user.founders.joins(:school).where(schools: { id: current_school }).exists?
    end

    def coach_dashboard_path
      view.course_coach_dashboard_path(current_user.faculty.joins(:school).where(schools: { id: current_school }).first.courses.first)
    end

    def school_logo_path
      if current_school.logo_on_light_bg.attached?
        current_school.logo_variant("thumb")
      else
        'shared/pupilfirst-icon.svg'
      end
    end
  end
end

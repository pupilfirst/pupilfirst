module Layouts
  class CoursePresenter < ::ApplicationPresenter
    def founder_profile?(course)
      current_user.founders.joins(:level).where(levels: { course_id: course }).exists?
    end

    def coach_profile?(course)
      current_user.faculty.joins(:courses).where(courses: { id: course }).exists?
    end

    def school_icon_path
      if current_school.icon.attached?
        current_school.icon_variant("thump")
      else
        'layouts/shared/favicon.png'
      end
    end
  end
end

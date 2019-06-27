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
        current_school.icon_variant("thumb")
      else
        '/favicon.png'
      end
    end

    def react_props(current_course)
      {
        courses: school_courses,
        currentCourse: course_data(current_course)
      }
    end

    def school_courses
      current_school.courses.map do |course|
        course_data(course)
      end
    end

    def course_data(course)
      {
        id: course.id,
        name: course.name,
        path: view.school_course_students_path(course)
      }
    end
  end
end

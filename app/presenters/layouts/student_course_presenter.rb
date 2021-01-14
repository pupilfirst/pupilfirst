module Layouts
  class StudentCoursePresenter < ::ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    private

    def props
      {
        current_course_id: @course.id,
        courses: courses,
        additional_links: additional_links,
        cover_image: @course.cover_url
      }
    end

    def courses
      if current_school_admin.present?
        # All courses are available to admins.
        current_school.courses
      else
        # Courses as a coach, plus courses as a student.
        courses_as_course_author = current_user.course_authors.present? ? Course.joins(:course_authors).where(course_authors: current_user.course_authors) : []
        courses_as_coach = current_coach.present? ? current_coach.courses : []
        courses_as_student = Course.joins(:founders).where(school: current_school, founders: { id: current_user.founders.select(:id) })
        (courses_as_course_author + courses_as_coach + courses_as_student).uniq
      end.map do |course|
        {
          id: course.id,
          name: course.name
        }
      end
    end

    def additional_links
      [report, leaderboard, review_dashboard, students] - [nil]
    end

    def review_dashboard
      if current_coach.present? && current_coach.courses.exists?(id: @course)
        "review"
      end
    end

    def leaderboard
      @course.enable_leaderboard ? "leaderboard" : nil
    end

    def report
      if current_user.present? && current_user.startups.not_dropped_out.joins(:level).exists?(levels: { course_id: @course.id })
        "report"
      end
    end

    def students
      if current_coach.present? && @course.in?(current_coach.courses)
        "students"
      end
    end
  end
end

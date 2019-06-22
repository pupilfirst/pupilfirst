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
        additional_links: additional_links
      }
    end

    def courses
      Course.joins(:founders).where(school: current_school, founders: { id: current_user.founders.select(:id) }).map do |course|
        {
          id: course.id,
          name: course.name
        }
      end
    end

    def additional_links
      [leaderboard, review_dashboard] - [nil]
    end

    def review_dashboard
      if current_coach.present? && @course.in?(current_coach.courses_with_dashboard)
        "review"
      end
    end

    def leaderboard
      # TODO: Add enable_leaderboard flag to course
      "leaderboard"
    end
  end
end

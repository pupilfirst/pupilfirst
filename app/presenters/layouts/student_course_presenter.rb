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

    # TODO: StudentCoursePresenter#additional_links should determine which additional links can 'actually' be shown to the user.
    def additional_links
      %w[calendar leaderboard review]
    end
  end
end

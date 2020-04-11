module Courses
  class ReviewPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "Review Dashboard | #{@course.name} | #{current_school.name}"
    end

    private

    def props
      students_presenter = StudentsPresenter.new(view, @course)

      {
        levels: levels,
        course_id: @course.id,
        current_coach: students_presenter.current_coach_details,
        team_coaches: students_presenter.team_coaches
      }
    end

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number')
      end
    end

    def user_names(timeline_event)
      timeline_event.founders.map do |founder|
        founder.user.name
      end.join(', ')
    end
  end
end

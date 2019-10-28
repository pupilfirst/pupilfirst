module Courses
  class StudentsPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "Students In Course | #{@course.name} | #{current_school.name}"
    end

    private

    def props
      {
        levels: levels,
        course: course_details
      }
    end

    def current_coach_details
      {
        name: current_user.name,
        avatar_url: current_user.image_or_avatar_url,
        title: current_user.title
      }
    end

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number')
      end
    end

    def course_details
      { id: @course.id, total_targets: @course.targets.count }
    end
  end
end

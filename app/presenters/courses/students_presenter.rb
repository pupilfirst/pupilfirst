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

    def levels
      @course.levels.map do |level|
        level.attributes.slice('id', 'name', 'number')
      end
    end

    def course_details
      { id: @course.id }
    end
  end
end

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
      @course.levels.where.not(number: 0).map do |level|
        level_attributes = level.attributes.slice('id', 'name', 'number')
        level_attributes.merge!(teams_in_level: level.startups.count)
      end
    end

    def course_details
      { id: @course.id }
    end
  end
end

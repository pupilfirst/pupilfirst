module Courses
  class StudentsPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "#{I18n.t('presenters.courses.students.students_in_course')} | #{@course.name} | #{current_school.name}"
    end

    private

    def props
      {
        levels: level_details,
        course: course_details,
        user_id: current_user.id
      }
    end

    def level_details
      @course.levels.as_json(only: %i[id name number])
    end

    def course_details
      { id: @course.id }
    end
  end
end

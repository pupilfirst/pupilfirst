module Courses
  class ApplyPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "Enroll to #{@course.name} | #{current_school.name}"
    end

    def props
      {
        authenticity_token: view.form_authenticity_token,
        course_id: @course.id,
        course_name: @course.name,
        course_description: @course.description,
        email: view.params[:email],
        name: view.params[:name]
      }
    end
  end
end

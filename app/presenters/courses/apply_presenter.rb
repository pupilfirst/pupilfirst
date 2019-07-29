module Courses
  class ApplyPresenter < ApplicationPresenter
    def initialize(view_context, course, applicant)
      @course = course
      @applicant = applicant
      super(view_context)
    end

    def page_title
      "Enroll to #{@course.name} | #{current_school.name}"
    end

    private

    def props
      {
        authenticity_token: view.form_authenticity_token,
        course_id: @course.id,
        course_name: @course.name,
        course_description: @course.description,
        applicant: @applicant.present? ? applicant_details : nil
      }
    end

    def applicant_details
      {
        email: @applicant.email,
        token: @applicant.login_token
      }
    end
  end
end

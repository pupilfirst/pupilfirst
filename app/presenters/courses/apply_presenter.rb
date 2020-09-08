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
        course_id: @course.id,
        course_name: @course.name,
        thumbnail_url: @course.thumbnail_url,
        email: view.params[:email],
        name: view.params[:name],
        privacy_policy: SchoolString::PrivacyPolicy.saved?(current_school),
        terms_and_conditions: SchoolString::TermsAndConditions.saved?(current_school)
      }
    end
  end
end

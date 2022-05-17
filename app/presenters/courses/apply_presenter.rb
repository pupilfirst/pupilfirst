module Courses
  class ApplyPresenter < ApplicationPresenter
    def initialize(view_context, course, show_checkbox_recaptcha)
      @course = course
      @show_checkbox_recaptcha = show_checkbox_recaptcha
      super(view_context)
    end

    def page_title
      "#{I18n.t('presenters.apply.page_title', course_name: @course.name)} | #{current_school.name}"
    end

    def thumbnail_url
      @course.thumbnail_url
    end

    def course_name
      @course.name
    end

    def privacy_policy?
      SchoolString::PrivacyPolicy.saved?(current_school)
    end

    def terms_and_conditions?
      SchoolString::TermsAndConditions.saved?(current_school)
    end
  end
end

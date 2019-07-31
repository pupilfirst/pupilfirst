module Courses
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "Enroll to #{@course.name} | #{current_school.name}"
    end

    def about
      if show_about?
        MarkdownIt::Parser.new(:commonmark).render(@course.about)
      end
    end

    def show_about?
      @course.about.present?
    end

    private

    def props
      {
        authenticity_token: view.form_authenticity_token,
        course_id: @course.id,
        course_name: @course.name,
        course_description: @course.description
      }
    end
  end
end

module Courses
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "#{@course.name} | #{current_school.name}"
    end

    def markdown_prop(markdown)
      { markdown: markdown, profile: 'permissive' }.to_json
    end

    def about
      @course.about if show_about?
    end

    def cover_image
      view.rails_public_blob_url(@course.cover) if @course.cover.attached?
    end

    def show_about?
      @course.about.present?
    end

    def user_is_student?
      return false if current_user.blank?

      current_user.students.joins(:course).exists?(courses: { id: @course.id })
    end
  end
end

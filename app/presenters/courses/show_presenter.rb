module Courses
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def page_title
      "#{@course.name} | #{current_school.name}"
    end

    def about
      if show_about?
        MarkdownIt::Parser.new(:commonmark).render(@course.about)
      end
    end

    def cover_image
      view.url_for(@course.cover) if @course.cover.attached?
    end

    def show_about?
      @course.about.present?
    end
  end
end

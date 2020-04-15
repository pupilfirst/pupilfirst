module Home
  class IndexPresenter < ApplicationPresenter
    def initialize(view_context, school)
      super(view_context)

      @school = school
    end

    def page_title
      @school.name
    end

    alias school_name page_title

    def courses
      @school.courses.where(featured: true).order(:name)
    end

    def cover_image
      view.url_for(@school.cover_image) if @school.cover_image.attached?
    end

    def course_thumbnail(course)
      view.url_for(course.thumbnail) if course.thumbnail.attached?
    end

    def about
      @school.about
    end

    def school_name_classes
      classes = "relative mx-auto flex flex-col justify-center text-white px-6 py-8 md:p-10"
      @school.about.present? ? "#{classes} text-left" : "#{classes} text-center"
    end

    def courses_as_student
      @courses_as_student ||= begin
        if current_user.present?
          current_user.founders.joins(:course).pluck('courses.id')
        else
          []
        end
      end
    end
  end
end

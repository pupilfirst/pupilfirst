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
      @school.courses.live.where(featured: true).order(:name)
    end

    def cover_image
      if @school.cover_image.attached?
        view.rails_public_blob_url(@school.cover_image)
      end
    end

    def course_thumbnail(course)
      view.rails_public_blob_url(course.thumbnail) if course.thumbnail.attached?
    end

    def about
      @school.about
    end

    def school_name_classes
      classes =
        'relative mx-auto flex flex-col justify-center text-white px-6 py-8 md:p-10'
      if @school.about.present?
        "#{classes} ltr:text-left rtl:text-right"
      else
        "#{classes} text-center"
      end
    end

    def courses_as_student
      @courses_as_student ||=
        begin
          if current_user.present?
            current_user
              .founders
              .includes(:cohort, :level)
              .each_with_object({}) do |student, courses|
                status =
                  if student.dropped_out_at?
                    :dropped_out
                  elsif student.access_ended?
                    :access_ended
                  else
                    :active
                  end

                courses[student.level.course_id] = status
              end
          else
            {}
          end
        end
    end
  end
end

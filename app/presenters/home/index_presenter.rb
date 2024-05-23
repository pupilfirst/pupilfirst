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
      @school.courses.with_attached_thumbnail.live.where(featured: true).order(sort_index: :asc)
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

    def courses_as_student
      @courses_as_student ||=
        begin
          if current_user.present?
            current_user
              .students
              .includes(:cohort)
              .each_with_object({}) do |student, courses|
                status =
                  if student.dropped_out_at?
                    :dropped_out
                  elsif student.access_ended?
                    :access_ended
                  else
                    :active
                  end

                courses[student.cohort.course_id] = status
              end
          else
            {}
          end
        end
    end
  end
end

module Layouts
  class StudentCoursePresenter < ::ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    private

    def props
      {
        current_course_id: @course.id,
        courses: courses,
        additional_links: additional_links,
        cover_image: @course.cover_url
      }
    end

    def courses
      if current_user.blank?
        current_school.courses.live.where(public_preview: true)
      elsif current_school_admin.present?
        # All courses are available to admins.
        current_school.courses.live
      else
        # Courses where user is an author...
        courses_as_course_author =
          if current_user.course_authors.present?
            Course
              .joins(:course_authors)
              .where(course_authors: current_user.course_authors)
          else
            []
          end

        # ...plus courses where user is a coach...
        courses_as_coach = current_coach.present? ? current_coach.courses : []

        # ...plus courses where user is a student...
        courses_as_student =
          Course
            .joins(:students)
            .where(
              school: current_school,
              students: {
                id: current_user.students.select(:id)
              }
            )

        # ...plus the current course if course has public preview.
        previewed_course = @course.public_preview? ? [@course] : []

        (
          courses_as_course_author + courses_as_coach + courses_as_student +
            previewed_course
        ).uniq
      end.as_json(only: %i[name id ends_at])
    end

    def additional_links
      [report, calendar, leaderboard, review_dashboard, students] - [nil]
    end

    def review_dashboard
      'review' if user_is_coach?
    end

    def leaderboard
      @course.enable_leaderboard ? 'leaderboard' : nil
    end

    def report
      'report' if user_is_student?
    end

    def calendar
      if current_school_admin.present? || user_is_student? || user_is_coach?
        'calendar'
      end
    end

    def user_is_student?
      current_user.present? &&
        current_user
          .students
          .not_dropped_out
          .joins(:cohort)
          .exists?(cohorts: { course_id: @course.id })
    end

    def user_is_coach?
      current_coach.present? && @course.in?(current_coach.courses)
    end

    def students
      'students' if user_is_coach?
    end
  end
end

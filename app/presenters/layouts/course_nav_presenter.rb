module Layouts
  class CourseNavPresenter < ::ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    def course_thumbnail
      return @course_thumbnail if defined?(@course_thumbnail)

      @course_thumbnail = {
        available: @course.thumbnail_url.present?,
        url: @course.thumbnail_url
      }
    end

    def courses
      if current_user.blank?
        current_school
          .courses
          .live
          .where(public_preview: true)
          .order("LOWER(name)")
      elsif current_school_admin.present?
        # All courses are available to admins.
        current_school.courses.live.order("LOWER(name)")
      else
        # Courses where user is an author...
        courses_as_course_author =
          if current_user.course_authors.present?
            Course.joins(:course_authors).where(
              course_authors: current_user.course_authors
            )
          else
            []
          end

        # ...plus courses where user is a student...
        courses_as_student =
          Course.joins(:students).where(
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
        ).uniq.sort_by { |course| course.name.downcase }
      end
    end

    def courses_as_coach
      @courses_as_coach ||= current_coach.present? ? current_coach.courses : []
    end

    def additional_links
      [report, calendar, leaderboard, review_dashboard, cohorts] - [nil]
    end

    def review_dashboard
      "review" if current_school_admin.present? || user_is_coach?
    end

    def leaderboard
      @course.enable_leaderboard ? "leaderboard" : nil
    end

    def report
      "report" if user_is_student?
    end

    def calendar
      if current_school_admin.present? || user_is_student? || user_is_coach?
        "calendar"
      end
    end

    def links
      %w[curriculum] + additional_links
    end

    def user_is_student?
      @user_is_student ||=
        current_user.present? &&
          current_user
            .students
            .not_dropped_out
            .joins(:cohort)
            .exists?(cohorts: { course_id: @course.id })
    end

    def user_is_coach?
      @user_is_coach ||=
        current_coach.present? && @course.in?(current_coach.courses)
    end

    def cohorts
      "cohorts" if current_school_admin.present? || user_is_coach?
    end

    def course_link(course)
      return if course.nil?

      default_path = view.curriculum_course_path(course)

      url =
        case view.request.path.split("/")[3]
        when "review"
          if courses_as_coach.include?(course)
            view.review_course_path(course)
          else
            default_path
          end
        when "cohorts"
          if courses_as_coach.include?(course)
            view.cohorts_course_path(course)
          else
            default_path
          end
        when "calendar"
          view.calendar_course_path(course)
        else
          view.curriculum_course_path(course)
        end

      { name: course.name, url: url }
    end

    def course_link_props
      {
        links: courses.map { |course| course_link(course) },
        selectedLink: course_link(@course),
        placeholder: "Select a course"
      }
    end

    def icon(link)
      case link
      when "curriculum"
        "if i-journal-text-light if-fw"
      when "report"
        "if i-graph-up-light"
      when "cohorts"
        "if i-users-light"
      when "review"
        "if i-clipboard-check-light"
      when "leaderboard"
        "if i-tachometer-alt-light"
      when "calendar"
        "if i-calendar-regular"
      end
    end
  end
end

module Layouts
  class AppRouterPresenter < ::ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    private

    def props
      { courses: course_details_array, current_user: user_details }
    end

    # private

    def user_details
      user = {
        name: current_user.name,
        title: current_user.full_title,
        is_admin: current_school_admin.present?,
        can_edit_profile: show_user_edit?
      }
      if current_user.avatar.attached?
        user[:avatar_url] = view.url_for(current_user.avatar_variant(:thumb))
      end
      user
    end

    def courses
      if current_user.blank?
        current_school.courses.live.where(public_preview: true)
      elsif current_school_admin.present?
        # All courses are available to admins.
        current_school.courses.live
      else
        # current course if course has public preview.
        previewed_course = @course.public_preview? ? [@course] : []

        (
          courses_with_author_access + courses_with_review_access +
            courses_with_student_profile + previewed_course
        ).uniq
      end
    end

    def courses_with_student_profile
      @courses_with_student_profile ||=
        begin
          Course
            .joins(:founders)
            .where(
              school: current_school,
              founders: {
                id: current_user.founders.select(:id)
              }
            )
        end
    end

    def courses_with_review_access
      @courses_with_review_access ||=
        begin
          current_coach.present? ? current_coach.courses : []
        end
    end

    def courses_with_review_access_ids
      @courses_with_review_access_ids ||= courses_with_review_access.pluck(:id)
    end

    def courses_with_author_access
      if current_user.course_authors.present?
        Course
          .joins(:course_authors)
          .where(course_authors: current_user.course_authors)
      else
        []
      end
    end

    def courses_with_author_access_ids
      @courses_with_author_access_ids ||= courses_with_author_access.pluck(:id)
    end

    def course_details_array
      courses
        .includes(:communities)
        .map do |course|
          {
            id: course.id,
            name: course.name,
            review: course.id.in?(courses_with_review_access_ids),
            author: course.id.in?(courses_with_author_access_ids),
            enable_leaderboard: course.enable_leaderboard?,
            description: course.description,
            exited: student_dropped_out(course.id),
            thumbnail_url: course.thumbnail_url,
            linked_communities:
              course
                .communities
                .select(:id, :name)
                .map { |c| { id: c.id.to_s, name: c.name } },
            access_ended: student_access_end(course.id),
            ended: course.ended?,
            is_student: student_profile?(course.id)
          }
        end
    end

    def student_profile?(course_id)
      courses_with_student_profile.detect { |c| c.id == course_id }.present?
    end

    def student_access_end(course_id)
      course_with_student =
        courses_with_student_profile.detect { |c| c.id == course_id }

      return false if course_with_student.blank?

      course_with_student[:access_ends_at].present? &&
        course_with_student[:access_ends_at].past?
    end

    def student_dropped_out(course_id)
      course_with_student =
        courses_with_student_profile.detect { |c| c.id == course_id }

      return false if course_with_student.blank?

      course_with_student[:dropped_out_at].present?
    end

    def show_user_edit?
      view.policy(current_user).edit?
    end
  end
end

module Users
  class DashboardPresenter < ApplicationPresenter
    def page_title
      I18n.t("shared.dashboard") + " | #{current_school.name}"
    end

    def props
      dashboard_props = {
        courses: course_details_array,
        current_school_admin: current_school_admin.present?,
        show_user_edit: show_user_edit?,
        communities: community_details_array,
        user_name: current_user.name,
        preferred_name: current_user.preferred_name,
        user_title: current_user.full_title,
        issued_certificates: issued_certificate_details,
        standing: standing
      }

      if current_user.avatar.attached?
        dashboard_props[:avatar_url] = view.rails_public_blob_url(
          current_user.avatar_variant(:thumb)
        )
      end

      dashboard_props
    end

    private

    def standing
      return unless Schools::Configuration.new(current_school).standing_enabled?

      current_standing =
        current_user
          .user_standings
          .includes(:standing)
          .live
          .order(created_at: :desc)
          .first
          &.standing || current_school.default_standing

      { name: current_standing.name, color: current_standing.color }
    end

    def issued_certificate_details
      current_user
        .issued_certificates
        .live
        .includes(:course)
        .map do |issued_certificate|
          issued_certificate
            .attributes
            .slice("id", "serial_number", "created_at")
            .merge(course_name: issued_certificate.course.name)
        end
    end

    def courses
      @courses ||=
        begin
          if current_school_admin.present?
            current_school
              .courses
              .joins(:cohorts)
              .where("cohorts.ends_at > ? OR cohorts.ends_at IS NULL", Time.now)
              .or(
                current_school.courses.live.where(
                  id: courses_with_student_profile.pluck(:course_id)
                )
              )
              .distinct
              .select("courses.*, LOWER(courses.name) AS lower_case_name")
              .order("lower_case_name")
          else
            current_school
              .courses
              .live
              .where(
                id:
                  (
                    courses_with_student_profile.pluck(:course_id) +
                      courses_with_review_access + courses_with_author_access
                  ).uniq
              )
              .order("LOWER(name)")
          end.with_attached_thumbnail
        end
    end

    def courses_with_student_profile
      @courses_with_student_profile ||=
        begin
          current_user
            .students
            .includes(:cohort)
            .map do |student|
              {
                course_id: student.cohort.course_id,
                dropped_out_at: student.dropped_out_at,
                ends_at: student.cohort.ends_at
              }
            end
        end
    end

    def courses_with_review_access
      @courses_with_review_access ||=
        begin
          if current_school_admin.present?
            current_school.courses.pluck(:id)
          elsif current_user.faculty.present?
            current_user.faculty.courses.pluck(:id)
          else
            []
          end
        end
    end

    def courses_with_author_access
      @courses_with_author_access ||=
        current_user.course_authors.pluck(:course_id)
    end

    def communities
      @communities ||=
        begin
          # All communities in school.
          communities_in_school = Community.where(school: current_school)

          if current_school_admin.present? || current_coach.present?
            # Coaches and school admins can access all communities in a school.
            communities_in_school
          else
            # Students can access communities linked to their courses, as long as they haven't dropped out.
            active_courses =
              Course
                .live
                .joins(cohorts: [students: :user])
                .where(users: { id: current_user })
                .where(students: { dropped_out_at: nil })
            communities_in_school
              .joins(:courses)
              .where(courses: { id: active_courses })
              .distinct
          end
        end
    end

    def community_details_array
      communities.map { |community| { id: community.id, name: community.name } }
    end

    def course_details_array
      courses
        .includes(:communities)
        .map do |course|
          {
            id: course.id,
            name: course.name,
            review: course.id.in?(courses_with_review_access),
            author: course.id.in?(courses_with_author_access),
            enable_leaderboard: course.enable_leaderboard?,
            description: course.description,
            exited: student_dropped_out(course.id),
            thumbnail_url: course.thumbnail_url,
            linked_communities: course.communities.pluck(:id).map(&:to_s),
            access_ended: student_access_end(course.id),
            ended: course.cohorts.active.blank?
          }
        end
    end

    def student_access_end(course_id)
      course_with_student =
        courses_with_student_profile.detect { |c| c[:course_id] == course_id }

      return false if course_with_student.blank?

      course_with_student[:ends_at].present? &&
        course_with_student[:ends_at].past?
    end

    def student_dropped_out(course_id)
      course_with_student =
        courses_with_student_profile.detect { |c| c[:course_id] == course_id }

      return false if course_with_student.blank?

      course_with_student[:dropped_out_at].present?
    end

    def show_user_edit?
      view.policy(current_user).edit?
    end
  end
end

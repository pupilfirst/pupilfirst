module Users
  class DashboardPresenter < ApplicationPresenter
    def page_title
      "Dashboard | #{current_school.name}"
    end

    def props
      dashboard_props = {
        courses: course_details_array,
        current_school_admin: current_school_admin.present?,
        show_user_edit: show_user_edit?,
        communities: community_details_array,
        user_name: current_user.name,
        user_title: current_user.full_title,
        issued_certificates: issued_certificate_details
      }

      if current_user.avatar.attached?
        dashboard_props[:avatar_url] = view.url_for(current_user.avatar_variant(:thumb))
      end

      dashboard_props
    end

    private

    def issued_certificate_details
      current_user.issued_certificates.live.includes(:course).map do |issued_certificate|
        issued_certificate.attributes.slice('id', 'serial_number', 'created_at').merge(
          course_name: issued_certificate.course.name
        )
      end
    end

    def courses
      @courses ||= begin
        if current_school_admin.present?
          current_school.courses
        else
          current_school.courses.where(id: (courses_with_student_profile.pluck(:course_id) + courses_with_review_access + courses_with_author_access).uniq)
        end.with_attached_thumbnail
      end
    end

    def courses_with_student_profile
      @courses_with_student_profile ||= begin
        current_user.founders.joins(:course).pluck(:course_id, :dropped_out_at).map do |course_id, dropped_out_at|
          {
            course_id: course_id,
            dropped_out_at: dropped_out_at
          }
        end
      end
    end

    def courses_with_review_access
      @courses_with_review_access ||= begin
        current_user.faculty.present? ? current_user.faculty.courses.pluck(:id) : []
      end
    end

    def courses_with_author_access
      @courses_with_author_access ||= current_user.course_authors.pluck(:course_id)
    end

    def communities
      @communities ||= begin
        # All communities in school.
        communities_in_school = Community.where(school: current_school)

        if current_school_admin.present? || current_coach.present?
          # Coaches and school admins can access all communities in a school.
          communities_in_school
        else
          # Students can access communities linked to their courses, as long as they haven't dropped out.
          active_courses = Course.joins(startups: [founders: :user]).where(users: { id: current_user }).where(startups: { dropped_out_at: nil })
          communities_in_school.joins(:courses).where(courses: { id: active_courses }).distinct
        end
      end
    end

    def community_details_array
      communities.map do |community|
        {
          id: community.id,
          name: community.name
        }
      end
    end

    def course_details_array
      courses.includes(:communities).map do |course|
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
          ended: course.ended?
        }
      end
    end

    def student_dropped_out(course_id)
      course_with_founder = courses_with_student_profile.detect { |c| c[:course_id] == course_id }
      course_with_founder.present? ? course_with_founder[:dropped_out_at].present? : false
    end

    def show_user_edit?
      view.policy(current_user).edit?
    end
  end
end

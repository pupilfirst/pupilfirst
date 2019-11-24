module Users
  class HomeV2Presenter < ApplicationPresenter
    def initialize(view_context)
      super(view_context)
    end

    def page_title
      "Home | #{current_school.name}"
    end

    def props
      home_props = {
        courses: course_details_array,
        current_school_admin: current_school_admin.present?,
        show_user_edit: show_user_edit?,
        communities: community_details_array,
        user_name: current_user.name,
        user_title: current_user.full_title
      }

      if current_user.avatar.attached?
        home_props[:avatar_url] = view.url_for(current_user.avatar_variant(:thumb))
      end

      home_props
    end

    private

    def courses
      @courses ||= begin
        if current_school_admin.present?
          current_school.courses
        else
          current_school.courses.where(id: (courses_with_student_profile.pluck(:course_id) + courses_with_review_access).uniq)
        end
      end
    end

    def courses_with_student_profile
      @courses_with_student_profile ||= begin
        current_user.founders.joins(:course).pluck(:course_id, :exited).map do |course_id, exited|
          {
            course_id: course_id,
            exited: exited
          }
        end
      end
    end

    def courses_with_review_access
      @courses_with_review_access ||= begin
        current_user.faculty.present? ? current_user.faculty.reviewable_courses.pluck(:id) : []
      end
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
          active_courses = Course.joins(founders: :user).where(users: { id: current_user }).where(founders: { exited: false })
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
          links: course_links(course),
          description: course.description,
          exited: student_exited(course.id),
          image_url: course.image_url,
          linked_communities: course.communities.pluck(:id).map(&:to_s)
        }
      end
    end

    def student_exited(course_id)
      course_with_founder = courses_with_student_profile.detect { |c| c[:course_id] == course_id }
      course_with_founder.present? ? course_with_founder[:exited] : false
    end

    def course_links(course)
      links = []
      links << 'curriculum'
      links << 'leaderboard' if course.enable_leaderboard?
      links << 'review' if course.id.in?(courses_with_review_access)
      links << 'students' if course.id.in?(courses_with_review_access)
      links
    end

    def show_user_edit?
      view.policy(current_user).edit?
    end
  end
end

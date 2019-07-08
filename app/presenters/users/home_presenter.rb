module Users
  class HomePresenter < ApplicationPresenter
    def initialize(view_context)
      super(view_context)
    end

    def page_title
      "Home | #{current_school.name}"
    end

    def course_details
      course_details = founders.map do |founder|
        course_detail = course_info(founder.course)
        course_detail[:cta] = cta_for_founder(founder)
        course_detail[:links] = founder.exited ? [] : founder_links(founder)
        course_detail[:founder_exited] = founder.exited
        course_detail
      end

      return course_details if current_coach.blank?

      add_review_links_for_coach(course_details)
    end

    def founders
      @founders ||= current_user.founders.joins(:school).where(schools: { id: current_school })
    end

    def show_profile_edit?
      founders.where(exited: false).any?
    end

    def user_profile
      @user_profile ||= UserProfile.where(user: current_user, school: current_school).first
    end

    def avatar
      if user_profile.avatar.attached?
        view.url_for(user_profile.avatar_variant(:mid))
      else
        user_profile.initials_avatar
      end
    end

    def show_communities?
      communities.any?
    end

    def communities
      @communities ||= begin
        communities_in_school = Community.where(school: current_school)

        if current_school_admin.present? || current_coach.present?
          communities_in_school
        else
          communities_in_school.joins(:courses).where(courses: { id: student_courses.pluck(:id) }).distinct
        end
      end
    end

    private

    def cta_for_founder(founder)
      text = if access_ended?(founder)
        'Course Ended'
      elsif !founder.dashboard_toured?
        'Start Course'
      else
        'Continue Course'
      end

      {
        text: text,
        link: view.course_path(founder.course)
      }
    end

    def student_courses
      @student_courses = current_school&.courses&.where(id: current_user.founders.joins(:course).pluck(:course_id))
    end

    def access_ended?(founder)
      founder.course.ends_at&.past? || founder.startup.access_ends_at&.past?
    end

    def add_review_links_for_coach(course_details)
      current_coach.courses_with_dashboard.inject(course_details) do |saved_courses, coach_course|
        saved_course, other_saved_courses = saved_courses.partition { |c| c[:course_id] == coach_course.id }
        saved_course = saved_course[0]

        if saved_course.present?
          saved_course[:cta] = review_link(coach_course, 'Review Submissions')
          saved_course[:links] << review_link(coach_course)
        else
          saved_course = course_details_for_coach(coach_course)
        end

        [saved_course] + other_saved_courses
      end
    end

    def course_details_for_coach(course)
      course_detail = course_info(course)
      course_detail[:cta] = review_link(course, 'Review Submissions')
      course_detail[:links] = [review_link(course)]
      course_detail
    end

    def founder_links(founder)
      return [] if founder.exited?

      [curriculum_link(founder), leaderboard_link(founder)] - [nil]
    end

    def review_link(course, text = 'Review')
      {
        text: text,
        link: view.course_coach_dashboard_path(course)
      }
    end

    def course_info(course)
      {
        course_id: course.id,
        course_name: course.name,
        course_description: course.description
      }
    end

    def curriculum_link(founder)
      {
        text: "Curriculum",
        link: view.course_path(founder.course)
      }
    end

    def leaderboard_link(founder)
      course = founder.course
      if course.enable_leaderboard
        {
          text: "Leaderboard",
          link: view.leaderboard_course_path(course)
        }
      end
    end
  end
end

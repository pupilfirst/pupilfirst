module Students
  class HomePresenter < ApplicationPresenter
    def initialize(view_context)
      super(view_context)
    end

    def founders
      @founders ||= current_user.founders.where(exited: false)
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

    def can_review?(course)
      return false if current_coach.blank?

      course.in? faculty_course
    end

    def additional_courses_for_faculty
      return [] if current_coach.blank?

      (student_courses - faculty_course) | (faculty_course - student_courses)
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

    def show_leaderboard_link?(course)
      lts = LeaderboardTimeService.new

      course_entries_last_week = LeaderboardEntry.joins(:course).where(
        courses: { id: course },
        period_from: lts.week_start,
        period_to: lts.week_end
      )
      course_entries_last_week.exists?
    end

    def course_cover_button_text(founder)
      founder.dashboard_toured? ? "Continue Course" : "Start Course"
    end

    private

    def student_courses
      @student_courses = current_school&.courses&.where(id: founders.joins(:course).pluck(:course_id))
    end

    def faculty_course
      @faculty_course = current_coach&.courses&.where(school: current_school)
    end
  end
end

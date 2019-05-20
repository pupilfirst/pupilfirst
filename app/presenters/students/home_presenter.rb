module Students
  class HomePresenter < ApplicationPresenter
    def initialize(view_context, user)
      super(view_context)

      @user = user
    end

    def founders
      @founders ||= @user.founders.where(exited: false)
    end

    def user_profile
      @user_profile ||= UserProfile.where(user: @user, school: current_school).first
    end

    def avatar
      if user_profile.avatar.attached?
        view.url_for(user_profile.avatar_variant(:mid))
      else
        user_profile.initials_avatar
      end
    end

    def communities
      course_ids = founders.joins(:course).pluck(:course_id)
      Community.where(school: current_school).joins(:courses).where(courses: { id: course_ids }).distinct
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
  end
end

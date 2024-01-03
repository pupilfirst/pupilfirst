module Users
  class StandingPresenter < ApplicationPresenter
    attr_reader :user
    def initialize(view_context, user)
      super(view_context)

      @user = user
    end

    def page_title(perspective)
      case perspective
      when :user
        view.t(
          "shared.user_standing.page_title_user",
          school_name: current_school.name
        )
      when :org_admin
        view.t(
          "shared.user_standing.page_title_org_admin",
          school_name: current_school.name
        )
      else
        raise "Unexpected perspective: #{perspective}"
      end
    end

    def standing_enabled?
      Schools::Configuration.new(current_school).standing_enabled?
    end

    def user_standings
      @user_standings ||=
        @user
          .user_standings
          .includes(:standing)
          .where(archived_at: nil)
          .order(created_at: :desc)
    end

    def school_default_standing
      Standing.find_by(school: current_school, default: true)
    end

    def current_standing
      @current_standing ||=
        user_standings.first&.standing || school_default_standing
    end

    def user_standings_count
      user_standings.length
    end
  end
end

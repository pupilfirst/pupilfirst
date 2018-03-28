ActiveAdmin.register_page 'Leaderboards' do
  controller do
    include DisableIntercom
  end

  menu parent: 'Startups'

  controller do
    def index
      @level = Level.find_by(number: level_number) || Level.find_by(number: 1)
      @week_start_date = start_date.present? ? DateTime.parse(start_date) : DatesService.last_week_start_date

      if params[:karma_points_filter].present?
        @leaderboard = Startups::LeaderboardService.new(@level).leaderboard(start_date: @week_start_date)
        @rank_changes_present = false
      else
        @leaderboard_with_change_in_rank = Startups::LeaderboardService.new(@level).leaderboard_with_change_in_rank
        @rank_changes_present = true
      end
    end

    private

    def start_date
      params[:karma_points_filter].try(:[], :week_starting_at)
    end

    def level_number
      params[:karma_points_filter].try(:[], :level)
    end
  end

  sidebar :filter_by_level_and_week_start_date do
    render 'admin/leaderboards/karma_points_filter'
  end

  content do
    render 'admin/leaderboards/karma_points'
  end
end

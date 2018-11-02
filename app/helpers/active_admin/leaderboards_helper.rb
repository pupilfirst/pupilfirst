module ActiveAdmin
  module LeaderboardsHelper
    def leaderboard_scope_class(level_number)
      if params[:level].present?
        params[:level].to_i == level_number ? 'selected' : ''
      else
        level_number == 1 ? 'selected' : ''
      end
    end

    def week_start_dates_for_filter
      last_week_start_date = DatesService.last_week_start_date

      # Create week start dates that will be used to filter leaderboards by week in AA.
      (0..9).map do |n|
        week_start_date = last_week_start_date - n.weeks
        [week_start_date.to_date, week_start_date]
      end
    end

    def levels_for_filter
      levels = Level.where.not(number: 0).order(number: :desc)
      levels.each_with_object([]) do |level, levels_for_filter|
        levels_for_filter << ["Level #{level.number}", level.number]
      end
    end
  end
end

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
      last_week_start_date = DatesService.last_week_start_date.to_datetime
      # Filter array stored in the format ["option", value] as required by select
      week_start_dates = [[last_week_start_date.to_date, last_week_start_date]]

      # Create another 9 week start dates that will be used to filter leaderboards by week in AA
      9.times do
        last_week_start_date -= 1.week
        week_start_dates << [last_week_start_date.to_date, last_week_start_date]
      end
      week_start_dates
    end

    def levels_for_filter
      levels = Level.where.not(number: 0).order(number: :desc)
      levels.each_with_object([]) do |level, levels_for_filter|
        levels_for_filter << ["Level #{level.number}", level.number]
      end
    end
  end
end

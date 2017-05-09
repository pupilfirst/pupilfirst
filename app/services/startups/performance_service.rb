module Startups
  class PerformanceService
    def leaderboard_rank(specified_startup)
      leaderboard_for_run = Startups::LeaderboardService.new(specified_startup.level).leaderboard
      return if leaderboard_for_run.nil?
      leaderboard_for_run.detect { |startup, _rank, _points| startup == specified_startup }&.second
    end

    def last_week_karma(specified_startup)
      weekly_karma_point = WeeklyKarmaPoint.where(startup_id: specified_startup.id, week_starting_at: last_week_start_date).first
      return if weekly_karma_point.nil?
      weekly_karma_point.points
    end

    # returns a relative performance measure for a startup as a %
    def relative_performance(startup)
      @level = startup.level
      karma = last_week_karma(startup)
      relative_measure(karma)
    end

    private

    # Starts on the week before last's Monday 6 PM IST.
    def last_week_start_date
      DatesService.last_week_start_date
    end

    def startup_points_hash
      @startup_points_hash ||= startup_with_points.each_with_object({}) do |startup, startup_points|
        startup_points[startup] = startup.weekly_karma_points.first.points
      end.to_h.extend(DescriptiveStatistics)
    end

    def startup_with_points
      Startup.not_dropped_out.where(level: @level)
        .includes(:weekly_karma_points)
        .where(weekly_karma_points: { week_starting_at: last_week_start_date })
        .where('weekly_karma_points.points > ?', 0)
    end

    def mean_karma
      startup_points_hash.mean
    end

    def standard_deviation_in_karma
      startup_points_hash.standard_deviation
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def relative_measure(karma)
      m = mean_karma
      s_d = standard_deviation_in_karma
      return 50 unless m&.positive? && s_d&.positive?

      return 10 if karma < (m - (2 * s_d))
      return 30 if karma.in?((m - (2 * s_d))..(m - s_d))
      return 50 if karma.in?((m - s_d)..(m + s_d))
      return 70 if karma.in?((m + s_d)..(m + (2 * s_d)))
      return 90 if karma > (m + (2 * s_d))
      50 # fall-back to average
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end

module Startups
  class PerformanceService
    # returns array of startup ids in the batch and their ranks
    def leaderboard(batch)
      @batch = batch
      @batch.present_week_number.in?(1..24) ? rank_list : nil
    end

    def leaderboard_rank(startup)
      leaderboard(startup.batch).detect { |startup_id, _rank| startup_id == startup.id }&.second
    end

    def last_week_karma(startup)
      @batch = startup.batch
      startups_sorted_by_points.detect { |startup_id, _points| startup_id == startup.id }&.second || 0
    end

    # returns a relative performance measure for a startup as a %
    def relative_performance(startup)
      @batch = startup.batch
      karma = last_week_karma(startup)
      relative_measure(karma)
    end

    # private

    def rank_list
      ranks_with_points + ranks_without_points
    end

    def ranks_with_points
      @last_points = nil
      @last_rank = nil
      startups_sorted_by_points.each_with_index.map { |startup_points, index| rank(startup_points, index) }
    end

    def ranks_without_points
      startups_without_points.each.map { |startup| [startup.id, last_rank_with_points + 1] }
    end

    def last_rank_with_points
      ranks_with_points.present? ? ranks_with_points[-1][-1] : 0
    end

    def rank(startup_points, index)
      startup_id, points = startup_points

      if @last_points == points
        rank = @last_rank
      else
        rank = index + 1
        @last_rank = rank
      end

      @last_points = points

      [startup_id, rank]
    end

    def startups_sorted_by_points
      startups_with_points.group(:startup_id).sum(:points).sort_by { |_startup_id, points| points }.reverse
    end

    def startups_with_points
      startups_in_batch.joins(:karma_points)
        .where('karma_points.created_at > ?', start_date)
        .where('karma_points.created_at < ?', end_date)
    end

    def startups_without_points
      startups_in_batch.where.not(id: startups_with_points.pluck(:startup_id).uniq)
    end

    def startups_in_batch
      Startup.not_dropped_out.where(batch: @batch)
    end

    # Starts on the week before last's Monday 6 PM IST.
    def start_date
      if monday? && before_evening?
        8.days.ago.beginning_of_week
      else
        7.days.ago.beginning_of_week
      end.in_time_zone('Asia/Calcutta') + 18.hours
    end

    # Ends on last week's Monday 6 PM IST.
    def end_date
      if monday? && before_evening?
        8.days.ago.end_of_week
      else
        7.days.ago.end_of_week
      end.in_time_zone('Asia/Calcutta') + 18.hours
    end

    def monday?
      Date.today.in_time_zone('Asia/Calcutta').wday == 1
    end

    def before_evening?
      Time.now.in_time_zone('Asia/Calcutta').hour < 18
    end

    def startup_points_hash
      @startup_points_hast ||= startups_sorted_by_points.to_h.extend(DescriptiveStatistics)
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
      return 10 if karma.in?((m + s_d)..(m + (2 * s_d)))
      return 90 if karma > (m + (2 * s_d))
      50 # fall-back to average
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end

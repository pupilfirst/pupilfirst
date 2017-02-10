module Startups
  class PerformanceService
    # returns leaderboard array of [startup, rank, points]
    def leaderboard(batch, start_date: nil, end_date: nil)
      @start_date = start_date || last_week_start_date
      @end_date = end_date || last_week_end_date
      @batch = batch

      @leaderboard = Hash.new do |hash, key|
        hash[key] = key.first.present_week_number.in?(1..24) ? rank_list : nil
      end

      @leaderboard[[@batch, @start_date, @end_date]]
    end

    # returns leaderboard array of [startup, rank, points, change_in_rank]
    def leaderboard_with_change_in_rank(batch)
      return nil unless batch.present_week_number.in?(1..24)

      change_in_rank = if batch.present_week_number == 1
        Array.new(batch.startups.count, 0)
      else
        current_leaderboard = leaderboard(batch)
        start_date_last_week = @start_date - 7.days
        end_date_last_week = @end_date - 7.days
        previous_leaderboard = leaderboard(batch, start_date: start_date_last_week, end_date: end_date_last_week)

        current_leaderboard.map do |startup_rank_points|
          previous_leaderboard.detect { |startup, _rank, _points| startup == startup_rank_points[0] }&.second - startup_rank_points[1]
        end
      end

      current_leaderboard.each_with_index.map { |startup_rank_points, index| startup_rank_points + [change_in_rank[index]] }
    end

    def leaderboard_rank(specified_startup)
      leaderboard_for_run = leaderboard(specified_startup.batch)
      return if leaderboard_for_run.nil?
      leaderboard_for_run.detect { |startup, _rank, _points| startup == specified_startup }&.second
    end

    def last_week_karma(specified_startup)
      leaderboard_for_run = leaderboard(specified_startup.batch)
      return if leaderboard_for_run.nil?
      leaderboard_for_run.detect { |startup, _rank, _points| startup == specified_startup }&.third
    end

    # returns a relative performance measure for a startup as a %
    def relative_performance(startup)
      @batch = startup.batch
      karma = last_week_karma(startup)
      relative_measure(karma)
    end

    private

    def rank_list
      ranks_with_points_for_run = ranks_with_points
      ranks_with_points_for_run + ranks_without_points(ranks_with_points_for_run)
    end

    def ranks_with_points
      @last_points = nil
      @last_rank = nil
      startups_sorted_by_points.each_with_index.map { |startup_points, index| rank(startup_points, index) }
    end

    def ranks_without_points(rank_with_points_for_run)
      # counts the startups which has the same last rank in the rank-list with points
      last_rank_count = rank_with_points_for_run.count { |x| x[1] == last_rank_with_points(rank_with_points_for_run) }
      startups_without_points.each.map { |startup| [startup, last_rank_with_points(rank_with_points_for_run) + last_rank_count, 0] }
    end

    def last_rank_with_points(rank_with_points_for_run)
      rank_with_points_for_run.present? ? rank_with_points_for_run[-1][1] : 0
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

      [Startup.find_by(id: startup_id), rank, points]
    end

    def startups_sorted_by_points
      startups_with_points.group(:startup_id).sum(:points).sort_by { |_startup_id, points| points }.reverse
    end

    def startups_with_points
      startups_in_batch.joins(:karma_points)
        .where('karma_points.created_at > ?', @start_date)
        .where('karma_points.created_at < ?', @end_date)
    end

    def startups_without_points
      startups_in_batch.where.not(id: startups_with_points.select(:startup_id).distinct(:startup_id))
    end

    def startups_in_batch
      Startup.not_dropped_out.where(batch: @batch)
    end

    # Starts on the week before last's Monday 6 PM IST.
    def last_week_start_date
      DatesService.last_week_start_date
    end

    # Ends on last week's Monday 6 PM IST.
    def last_week_end_date
      DatesService.last_week_end_date
    end

    def startup_points_hash
      @startup_points_hash ||= startups_sorted_by_points.to_h.extend(DescriptiveStatistics)
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

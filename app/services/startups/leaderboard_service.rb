module Startups
  class LeaderboardService
    def self.pending?
      WeeklyKarmaPoint.where(week_starting_at: DatesService.last_week_start_date).blank?
    end

    def initialize(level)
      @level = level
    end

    # returns leaderboard array of [startup, rank, points]
    def leaderboard(start_date: nil)
      week_start_date = start_date || last_week_start_date

      raise 'Leaderboard cannot be generated for Level 0' if @level.number.zero?

      @leaderboard = Hash.new do |hash, key|
        hash[key] = rank_list(@level, week_start_date)
      end

      @leaderboard[[@level, week_start_date]]
    end

    def leaderboard_with_change_in_rank
      current_leaderboard = leaderboard

      start_date_last_week = last_week_start_date - 7.days

      # Set rank change to zero if no WeeklyKarmaPoint is created for the level last week
      change_in_rank = if WeeklyKarmaPoint.where(week_starting_at: start_date_last_week, level_id: @level.id).blank?
        Array.new(current_leaderboard.count, 0)
      else
        # Calculate change in rank by checking against the previous leaderboard.
        previous_leaderboard = leaderboard(start_date: start_date_last_week)

        current_leaderboard.map do |startup, rank, _points|
          previous_rank = previous_leaderboard.detect do |previous_startup, _previous_rank, _previous_points|
            previous_startup == startup
          end&.second
          previous_rank.present? ? (previous_rank - rank) : 0
        end
      end

      # Add the change in rank as fourth element in return array.
      current_leaderboard.each_with_index.map do |startup_rank_points, index|
        startup_rank_points + [change_in_rank[index]]
      end
    end

    private

    def rank_list(level, week_start_date)
      startup_and_points = startups_sorted_by_points(level, week_start_date).each_with_object({}) do |startup, hash|
        # Weekly karma point is already included, so assume 'startup.weekly_karma_points' returns the weekly karma point
        # with the given week_start_date only
        hash[startup] = startup.weekly_karma_points.first.points
      end

      rank(startup_and_points)
    end

    # Compare each startup and points entry against the previous one to determine the rank.
    def rank(startup_and_points)
      startup_and_points.each_with_object([]) do |(startup, points), startup_points_rank|
        startup_rank_with_points = if startup_points_rank.blank?
          [startup, 1, points]
        elsif startup_points_rank.last[2] == points
          [startup, startup_points_rank.last[1], points]
        else
          [startup, startup_points_rank.length + 1, points]
        end

        startup_points_rank << startup_rank_with_points
      end
    end

    def startups_sorted_by_points(level, week_start_date)
      startups_in_level(level).includes(:weekly_karma_points)
        .where(weekly_karma_points: { week_starting_at: week_start_date })
        .order('weekly_karma_points.points DESC')
    end

    def startups_in_level(level)
      Startup.not_dropped_out.where(level: level)
    end

    # Starts on the week before last's Monday 6 PM IST.
    def last_week_start_date
      DatesService.last_week_start_date
    end
  end
end

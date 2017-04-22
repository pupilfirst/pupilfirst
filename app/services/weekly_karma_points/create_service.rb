module WeeklyKarmaPoints
  # The service creates entries of weekly karma points for active startups. This will be used to create
  # leaderboards level-wise. The service will be executed by a task scheduled to run every Monday at 5:55 PM IST
  class CreateService
    def execute
      create_weekly_karma_points
    end

    private

    def create_weekly_karma_points
      if startups_with_points_last_week.present?

        startups_with_points_last_week.each do |startup_points|
          WeeklyKarmaPoint.create!(
            week_starting_at: last_week_start_date,
            startup_id: startup_points.first,
            level_id: startup_levels[startup_points.first],
            points: startup_points.second
          )
        end
      end

      if startups_inactive_last_week.present?

        startups_inactive_last_week.each do |startup_id|
          WeeklyKarmaPoint.create!(
            week_starting_at: last_week_start_date,
            startup_id: startup_id,
            level_id: startup_levels[startup_id],
            points: 0
          )
        end
      end
    end

    # Returns startups active last week along with total karma points earned for the week
    def startups_with_points_last_week
      Startup.admitted.not_dropped_out.joins(:karma_points)
        .where('karma_points.created_at > ?', last_week_start_date)
        .where('karma_points.created_at < ?', last_week_end_date).group(:startup_id).sum(:points)
    end

    # Returns id's of all startups that had some activity in the last 2 months
    def active_startups
      Startup.admitted.not_dropped_out.joins(:karma_points).where('karma_points.created_at > ?', 2.months.ago).distinct.pluck(:id)
    end

    # Returns ids of startups that had no activity last week but are active startups in the platform
    def startups_inactive_last_week
      active_startups - startups_with_points_last_week.keys
    end

    # Starts on Monday of the week before at 6 PM IST.
    def last_week_start_date
      1.week.ago.beginning_of_week.in_time_zone('Asia/Calcutta') + 18.hours
    end

    # Ends this week's Monday 6:00 PM IST.
    def last_week_end_date
      Time.now.beginning_of_week.in_time_zone('Asia/Calcutta') + 18.hours
    end

    # Returns a hash that maps active startups to its level.
    def startup_levels
      @startup_levels = {}

      active_startups.each do |startup_id|
        @startup_levels[startup_id] = Startup.find(startup_id).level_id
      end

      @startup_levels
    end
  end
end

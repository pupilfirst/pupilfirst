module WeeklyKarmaPoints
  # The service creates entries of weekly karma points for active startups. This will be used to create
  # leaderboards level-wise. The service will be executed by a task scheduled to run every Monday at 18:00 IST
  #
  # @param week_at [Time] Set this to compute karma points for the week containing supplied time.
  class CreateService
    def initialize(week_at: 1.hour.ago)
      @week_at = week_at
    end

    def execute
      startups_with_points_last_week.each do |startup_id, points|
        WeeklyKarmaPoint.create!(
          week_starting_at: week_start_date,
          startup_id: startup_id,
          level_id: startup_levels[startup_id],
          points: points
        )
      end

      startups_inactive_last_week.each do |startup_id|
        WeeklyKarmaPoint.create!(
          week_starting_at: week_start_date,
          startup_id: startup_id,
          level_id: startup_levels[startup_id],
          points: 0
        )
      end
    end

    private

    # Returns startups active last week along with total karma points earned for the week
    def startups_with_points_last_week
      @startups_with_points_last_week ||= begin
        Startup.admitted
          .not_dropped_out
          .joins(:karma_points)
          .where('karma_points.created_at > ?', week_start_date)
          .where('karma_points.created_at < ?', week_end_date)
          .group(:startup_id)
          .sum(:points)
      end
    end

    # Returns id's of all startups that had some activity in the last 2 months
    def active_startups
      @active_startups ||= begin
        Startup.admitted
          .not_dropped_out
          .joins(:karma_points)
          .where('karma_points.created_at > ?', 2.months.ago)
          .distinct
          .pluck(:id)
      end
    end

    # Returns ids of startups that had no activity last week but are active startups in the platform
    def startups_inactive_last_week
      active_startups - startups_with_points_last_week.keys
    end

    # Starts on Monday of the week before at 6 PM IST.
    def week_start_date
      @week_start_date ||= DatesService.week_start(@week_at)
    end

    # Ends this week's Monday 6:00 PM IST.
    def week_end_date
      @week_end_date ||= DatesService.week_end(@week_at)
    end

    # Returns a hash that maps active startups to its level.
    def startup_levels
      @startup_levels ||= begin

        active_startups.each_with_object({}) do |startup_id, hash|
          hash[startup_id] = Startup.find(startup_id).level_id
        end

      end
    end
  end
end

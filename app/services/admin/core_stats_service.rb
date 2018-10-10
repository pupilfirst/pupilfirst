module Admin
  # Calculates the core stats of SV.CO.
  #
  # The calculated stats include the Net Promoter Score collected via platform feedback
  # as well as count and percentages of daily, weekly and monthly active users.
  class CoreStatsService
    # SUBSCRIPTION_MODEL_START_DATE = Date.parse('2017-05-8').beginning_of_day.freeze

    def stats
      {
        nps: nps,
        nps_count: nps_count,
        slack: active_user_stats(:slack),
        web: active_user_stats(:web),
        total: active_user_stats(:total)
      }
    end

    private

    # Count of founders who have given us an NPS.
    def nps_count
      @nps_count ||= latest_scored_feedback.count
    end

    # The present NPS.
    def nps
      promoters = latest_scored_feedback.where('promoter_score > ?', 8).count
      detractors = latest_scored_feedback.where('promoter_score < ?', 7).count
      nps_count.zero? ? 0 : ((promoters - detractors).to_f / nps_count) * 100
    end

    # Latest scored feedback per founder.
    def latest_scored_feedback
      PlatformFeedback.where(id: PlatformFeedback.select('distinct on (founder_id) id').order('founder_id, created_at desc'))
    end

    # Daily, weekly and monthly active user stats on a given platform.
    def active_user_stats(platform)
      {
        dau: active_user_count(platform, :daily),
        percentage_dau: active_user_percentage(platform, :daily),
        wau: active_user_count(platform, :weekly),
        percentage_wau: active_user_percentage(platform, :weekly),
        mau: active_user_count(platform, :monthly),
        percentage_mau: active_user_percentage(platform, :monthly),
        wau_trend: wau_trend(platform)
      }
    end

    # Count of admitted founders active on a specified platform for a specified duration.
    def active_user_count(platform, duration)
      send("#{platform}_active_user_count", start_time(duration))
    end

    # Percentage of admitted founders active on a specified platform for a specified duration.
    def active_user_percentage(platform, duration)
      founder_count = Founder.count
      value = active_user_count(platform, duration)
      founder_count.zero? ? 0 : (value.to_f / founder_count) * 100
    end

    # Start time to count active users from for a specified duration (:daily, :weekly or :monthly).
    def start_time(duration)
      { daily: 1, weekly: 8, monthly: 31 }[duration].days.ago.beginning_of_day
    end

    # Count of admitted founders active on Public Slack from a specified period, until yesterday.
    def slack_active_user_count(start_time, end_time = 1.day.ago.end_of_day)
      active_user_on_slack(start_time, end_time).distinct.count
    end

    # Count of admitted founders active on web from a specified period, until yesterday.
    def web_active_user_count(start_time, end_time = 1.day.ago.end_of_day)
      active_user_on_web(start_time, end_time).distinct.count
    end

    # Admitted founders active on Public Slack OR web in a specified window.
    def total_active_user_count(start_time, end_time = 1.day.ago.end_of_day)
      (active_user_on_slack(start_time, end_time) + active_user_on_web(start_time, end_time)).compact.uniq.count
    end

    # Admitted founders active on Public Slack in a specified window.
    def active_user_on_slack(start_time, end_time = 1.day.ago.end_of_day)
      Founder.active_on_slack(start_time, end_time)
    end

    # Admitted founders active on web in a specified window.
    def active_user_on_web(start_time, end_time = 1.day.ago.end_of_day)
      Founder.active_on_web(start_time, end_time)
    end

    # Weekly Active User trend for the last 7 weeks for a specified platform.
    def wau_trend(platform)
      8.downto(1).map do |x|
        send("#{platform}_active_user_count", (8 * x).days.ago.beginning_of_day, (8 * x - 7).days.ago.end_of_day)
      end
    end
  end
end

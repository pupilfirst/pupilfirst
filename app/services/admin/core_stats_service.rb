module Admin
  class CoreStatsService
    def fetch
      {
        nps: nps,
        nps_count: nps_count,
        slack: au_stats(:slack),
        web: au_stats(:web),
        total: au_stats(:total)
      }
    end

    private

    # Count of founders who have given us an NPS.
    def nps_count
      latest_scored_feedback.count
    end

    # The present NPS.
    def nps
      promoters = latest_scored_feedback.count { |feedback| feedback.promoter_score > 8 }
      detractors = latest_scored_feedback.count { |feedback| feedback.promoter_score < 7 }
      nps_count.zero? ? 0 : ((promoters - detractors).to_f / nps_count) * 100
    end

    # Latest scored feedback per founder.
    def latest_scored_feedback
      @latest_scored_feedback ||= PlatformFeedback.scored.select('DISTINCT ON (founder_id) *').order('founder_id, created_at DESC').to_a
    end

    # Daily, weekly and monthly active user stats on a given platform.
    def au_stats(platform)
      {
        dau: au_count(platform, :daily),
        percentage_dau: au_percentage(platform, :daily),
        wau: au_count(platform, :weekly),
        percentage_wau: au_percentage(platform, :weekly),
        mau: au_count(platform, :monthly),
        percentage_mau: au_percentage(platform, :monthly),
        wau_trend: wau_trend(platform)
      }
    end

    # Count of admitted founders active on a specified platform for a specified duration.
    def au_count(platform, duration)
      send("#{platform}_au_count", start_time(duration))
    end

    # Percentage of admitted founders active on a specified platform for a specified duration.
    def au_percentage(platform, duration)
      founder_percentage(au_count(platform, duration))
    end

    # Start time to count active users from for a specified duration (:daily, :weekly or :monthly).
    def start_time(duration)
      { daily: 1, weekly: 8, monthly: 31 }[duration].days.ago.beginning_of_day
    end

    # Count of admitted founders active on Public Slack from a specified period, until yesterday.
    def slack_au_count(start_time, end_time = 1.day.ago.end_of_day)
      au_on_slack(start_time, end_time).distinct.count
    end

    # Count of admitted founders active on web from a specified period, until yesterday.
    def web_au_count(start_time, end_time = 1.day.ago.end_of_day)
      au_on_web(start_time, end_time).distinct.count
    end

    # Admitted founders active on Public Slack OR web in a specified window.
    def total_au_count(start_time, end_time = 1.day.ago.end_of_day)
      (au_on_slack(start_time, end_time) + au_on_web(start_time, end_time)).compact.uniq.count
    end

    # Admitted founders active on Public Slack in a specified window.
    def au_on_slack(start_time, end_time = 1.day.ago.end_of_day)
      candidate_founders.active_on_slack(start_time, end_time)
    end

    # Admitted founders active on web in a specified window.
    def au_on_web(start_time, end_time = 1.day.ago.end_of_day)
      candidate_founders.active_on_web(start_time, end_time)
    end

    # Weekly Active User trend for the last 7 weeks for a specified platform.
    def wau_trend(platform)
      7.downto(0).to_a.map do |x|
        send("#{platform}_au_count", x.weeks.ago.beginning_of_week, x.weeks.ago.end_of_week)
      end
    end

    # Total number of admitted founders.
    def founder_count
      @founder_count ||= candidate_founders.count
    end

    # Percentage of admitted founders for the given metric.
    def founder_percentage(metric)
      founder_count.zero? ? 0 : (metric.to_f / founder_count) * 100
    end

    SUBSCRIPTION_MODEL_START_DATE = Date.parse('2017-05-8').beginning_of_day

    # Founders to be considered for calculating the metrics - includes only 'admitted' founders under the subscription model
    def candidate_founders
      Founder.admitted.not_dropped_out.not_exited.where('founders.created_at > ?', SUBSCRIPTION_MODEL_START_DATE)
    end
  end
end

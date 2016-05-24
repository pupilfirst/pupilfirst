module ActiveAdmin
  # rubocop:disable Metrics/ModuleLength
  module DashboardHelper
    def days_elapsed
      (Date.today - batch_selected.start_date).to_i
    end

    def batch_duration
      (batch_selected.end_date - batch_selected.start_date).to_i
    end

    def percentage_completed_days
      ((days_elapsed.to_f / batch_duration) * 100).round
    end

    def batch_progress_text
      if batch_selected.start_date > Time.now
        "Batch starting on #{batch_selected.start_date.strftime('%B %e')}"
      elsif batch_selected.end_date < Time.now
        "Batch ended on #{batch_selected.end_date.strftime('%B %e')}"
      else
        "Day #{days_elapsed} of #{batch_duration} — #{percentage_completed_days}% of Program Complete"
      end
    end

    def total_founder_count
      Founder.not_dropped_out.find_by_batch(batch_selected).count
    end

    def dau_on_slack
      Founder.active_founders_on_slack(since: Time.now.beginning_of_day, upto: Time.now, batch: batch_selected)
    end

    def percentage_dau_on_slack
      (dau_on_slack.count.to_f / total_founder_count) * 100
    end

    def dau_on_web
      Founder.active_founders_on_web(since: Time.now.beginning_of_day, upto: Time.now, batch: batch_selected)
    end

    def percentage_dau_on_web
      (dau_on_web.count.to_f / total_founder_count) * 100
    end

    def total_dau_count
      (dau_on_slack + dau_on_web).compact.uniq.count
    end

    def total_dau_percentage
      (total_dau_count.to_f / total_founder_count) * 100
    end

    def wau_on_slack
      Founder.active_founders_on_slack(since: Time.now.beginning_of_week, upto: Time.now, batch: batch_selected)
    end

    def percentage_wau_on_slack
      (wau_on_slack.count.to_f / total_founder_count) * 100
    end

    def wau_on_web
      Founder.active_founders_on_web(since: Time.now.beginning_of_week, upto: Time.now, batch: batch_selected)
    end

    def percentage_wau_on_web
      (wau_on_web.count.to_f / total_founder_count) * 100
    end

    def total_wau_count
      (wau_on_slack + wau_on_web).compact.uniq.count
    end

    def total_wau_percentage
      (total_wau_count.to_f / total_founder_count) * 100
    end

    def mau_on_slack
      Founder.active_founders_on_slack(since: Time.now.beginning_of_month, upto: Time.now, batch: batch_selected)
    end

    def percentage_mau_on_slack
      (mau_on_slack.count.to_f / total_founder_count) * 100
    end

    def mau_on_web
      Founder.active_founders_on_web(since: Time.now.beginning_of_month, upto: Time.now, batch: batch_selected)
    end

    def percentage_mau_on_web
      (mau_on_web.count.to_f / total_founder_count) * 100
    end

    def total_mau_count
      (mau_on_slack + mau_on_web).compact.uniq.count
    end

    def total_mau_percentage
      (total_mau_count.to_f / total_founder_count) * 100
    end

    def wau_trend_on_slack
      7.downto(0).to_a.map do |x|
        Founder.active_founders_on_slack(since: x.week.ago.beginning_of_week, upto: x.week.ago.end_of_week, batch: batch_selected).count
      end
    end

    def wau_trend_on_web
      7.downto(0).to_a.map do |x|
        Founder.active_founders_on_web(since: x.week.ago.beginning_of_week, upto: x.week.ago.end_of_week, batch: batch_selected).count
      end
    end

    def wau_trend_in_total
      7.downto(0).to_a.map do |x|
        (Founder.active_founders_on_slack(since: x.week.ago.beginning_of_week, upto: x.week.ago.end_of_week, batch: batch_selected) +
          Founder.active_founders_on_web(since: x.week.ago.beginning_of_week, upto: x.week.ago.end_of_week, batch: batch_selected)).compact.uniq.count
      end
    end

    def promoter_score_text
      "Net Promoter Score: #{present_nps} (from #{source_of_nps})"
    end

    def present_nps
      PlatformFeedback.average(:promoter_score).round(1).to_s('+F')
    end

    def source_of_nps
      "#{count_of_PS} Platform Feedback"
    end

    def count_of_ps
      PlatformFeedback.where.not(promoter_score: nil).count
    end
  end
  # rubocop:enable Metrics/ModuleLength
end

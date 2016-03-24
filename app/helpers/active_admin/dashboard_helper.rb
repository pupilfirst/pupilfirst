module ActiveAdmin
  module DashboardHelper
    def batch_selected
      params[:batch].present? ? Batch.find(params[:batch]) : Batch.current_or_last
    end

    def total_founder_count
      Founder.find_by_batch(batch_selected).count
    end

    def dau_on_slack
      Founder.active_founders_on_slack(since: 1.day.ago, batch: batch_selected)
    end

    def percentage_dau_on_slack
      (dau_on_slack.count.to_f / total_founder_count) * 100
    end

    def dau_on_web
      Founder.active_founders_on_web(since: 1.day.ago, batch: batch_selected)
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
      Founder.active_founders_on_slack(since: 1.week.ago, batch: batch_selected)
    end

    def percentage_wau_on_slack
      (wau_on_slack.count.to_f / total_founder_count) * 100
    end

    def wau_on_web
      Founder.active_founders_on_web(since: 1.week.ago, batch: batch_selected)
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
      Founder.active_founders_on_slack(since: 1.month.ago, batch: batch_selected)
    end

    def percentage_mau_on_slack
      (mau_on_slack.count.to_f / total_founder_count) * 100
    end

    def mau_on_web
      Founder.active_founders_on_web(since: 1.month.ago, batch: batch_selected)
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
      8.downto(1).to_a.map { |x| Founder.active_founders_on_slack(since: x.week.ago, upto: (x - 1).week.ago, batch: batch_selected).count }
    end

    def wau_trend_on_web
      8.downto(1).to_a.map { |x| Founder.active_founders_on_web(since: x.week.ago, upto: (x - 1).week.ago, batch: batch_selected).count }
    end

    def wau_trend_in_total
      8.downto(1).to_a.map do |x|
        (Founder.active_founders_on_slack(since: x.week.ago, upto: (x - 1).week.ago, batch: batch_selected) +
          Founder.active_founders_on_web(since: x.week.ago, upto: (x - 1).week.ago, batch: batch_selected)).compact.uniq.count
      end
    end
  end
end

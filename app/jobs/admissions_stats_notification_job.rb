# Sends membership stats for yesterday to Slack's #memberships channel.
class AdmissionsStatsNotificationJob < ApplicationJob
  queue_as :default

  def perform
    slack_webhook_url = Rails.application.secrets.slack_memberships_webhook_url
    json_payload = { text: membership_stats }.to_json
    RestClient.post(slack_webhook_url, json_payload)
  end

  private

  def membership_stats
    <<~MESSAGE
      *Here are the membership stats for yesterday:*

      > Unique Visits: *#{unique_visits_yesterday}*
      #{funnel_stats}

      *And the stats since Jan 9:*

      > Unique Visits: *#{unique_visits_since_jan_9}*
      #{complete_funnel_stats}

      <#{dashboard_url}|:bar_chart: View Dashboard>
    MESSAGE
  end

  def format_for_slack(stats)
    stats.each_with_object([]) do |(stat_title, stat_value), stats_array|
      stats_array << "> #{stat_title}: *#{stat_value}*"
    end.join("\n")
  end

  def complete_funnel_stats
    stats = AdmissionStats::FunnelStatsService.new('2018-01-09', Date.today.end_of_day).load
    format_for_slack(stats)
  end

  def funnel_stats
    stats = AdmissionStats::FunnelStatsService.new.load
    format_for_slack(stats)
  end

  def unique_visits_yesterday
    admitted_users = Founder.admitted.pluck(:user_id)
    new_user_visits = Visit.where(started_at: 1.day.ago.beginning_of_day..1.day.ago.end_of_day).where.not(user_id: admitted_users).count
    non_user_visits = Visit.where(started_at: 1.day.ago.beginning_of_day..1.day.ago.end_of_day).where(user_id: nil).count
    new_user_visits + non_user_visits
  end

  def unique_visits_since_jan_9
    Visit.where(started_at: Date.parse('2018-01-9').beginning_of_day..Date.today.end_of_day).count
  end

  def dashboard_url
    Rails.application.routes.url_helpers.admin_admissions_dashboard_url
  end
end

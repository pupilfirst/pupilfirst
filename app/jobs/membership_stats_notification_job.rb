# Sends membership stats for yesterday to Slack's #memberships channel.
class MembershipStatsNotificationJob < ApplicationJob
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

      *And the stats since May 8:*

      > Unique Visits: *#{unique_visits_since_may_8}*
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
    stats = AdmissionStats::FunnelStatsService.new('2017-05-08', Date.today.end_of_day).load
    format_for_slack(stats)
  end

  def funnel_stats
    stats = AdmissionStats::FunnelStatsService.new.load
    format_for_slack(stats)
  end

  def unique_visits_yesterday
    Visit.where(started_at: 1.day.ago.beginning_of_day..1.day.ago.end_of_day).count
  end

  def unique_visits_since_may_8
    Visit.where(started_at: Date.parse('2017-05-8').beginning_of_day..Date.today.end_of_day).count
  end

  def dashboard_url
    Rails.application.routes.url_helpers.admin_admissions_dashboard_url
  end
end

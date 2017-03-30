class AdmissionStatsNotificationJob < ApplicationJob
  queue_as :default
  attr_reader :application_round, :stats

  def perform
    @application_round = ApplicationRound.open_for_applications.order('starts_at DESC').first
    return if application_round.blank?
    @stats = AdmissionStatsService.load_stats(application_round)

    slack_webhook_url = Rails.application.secrets.slack_general_webhook_url
    json_payload = { 'text': admission_stats_summary }.to_json
    RestClient.post(slack_webhook_url, json_payload)
  end

  private

  def admission_stats_summary
    <<~MESSAGE
      > Here are the *Admission Campaign Stats for #{application_round.display_name}* today:
      *Campaign Progress:* Day #{days_passed}/#{total_days} (#{days_left} days left)
      *Target Achieved:* #{stats[:paid_applications]}/#{target_count} applications.
      *Payments Completed:* #{stats[:paid_applications]} (+#{stats[:paid_applications_today]})
      :point_up_2: _Note that #{stats[:paid_from_earlier_rounds]} of these were moved-in from earlier batches._
      *Payments Intiated:* #{stats[:payment_initiated]} (+#{stats[:payment_initiated_today]})
      *Applications Started:* #{stats[:submitted_applications]} (+#{stats[:submitted_applications_today]})
      *Paid Applications From:* #{state_wise_paid_count}
      *Top References Today:* #{top_references_today}
      *Unique Visits Today:* #{stats[:total_visits_today]}

      <#{dashboard_url}|:bar_chart: View Dashboard>
    MESSAGE
  end

  def state_wise_paid_count
    states_with_count = State.focused_for_admissions.each_with_object([]) do |state, message_components|
      count = stats[:state_wise_stats][state.name.to_sym][:paid_applications]
      message_components << "#{state.name} (#{count})" if count.positive?
    end

    others_count = stats[:state_wise_stats][:Others][:paid_applications]
    states_with_count << "Others (#{others_count})" if others_count.positive?

    states_with_count.join(', ')
  end

  def dashboard_url
    Rails.application.routes.url_helpers.admin_admissions_dashboard_url(round: application_round.id)
  end

  def days_passed
    application_round.campaign_days_passed
  end

  def total_days
    application_round.total_campaign_days
  end

  def days_left
    application_round.campaign_days_left
  end

  def target_count
    application_round.target_application_count
  end

  def top_references_today
    stats[:top_references_today].map { |r| "#{r[0]}(#{r[1]})" }.join(', ')
  end
end

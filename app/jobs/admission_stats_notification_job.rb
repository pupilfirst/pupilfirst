class AdmissionStatsNotificationJob < ActiveJob::Base
  queue_as :default
  attr_reader :batch, :stats

  def perform
    @batch = Batch.open_for_applications.order(:start_date).first.decorate
    return unless batch.present?
    @stats = AdmissionStatsService.load_stats(batch)

    slack_webhook_url = Rails.application.secrets.slack_general_webhook_url
    json_payload = { 'text': admission_stats_summary }.to_json
    RestClient.post(slack_webhook_url, json_payload)
  end

  private

  def admission_stats_summary
    <<~MESSAGE
      > Here are the *Admission Campaign Stats for Batch #{batch.batch_number}* today:
      *Campaign Progress:* Day #{days_passed}/#{total_days} (#{days_left} days left)
      *Target Achieved:* #{stats[:paid_applications]}/#{target_count} applications.
      *Payments Completed:* #{stats[:paid_applications]} (+#{stats[:paid_applications_today]})
      :point_up_2: _Note that #{stats[:paid_from_earlier_batches]} of these were moved-in from earlier batches._
      *Payments Intiated:* #{stats[:payment_initiated]} (+#{stats[:payment_initiated_today]})
      *Applications Started:* #{stats[:submitted_applications]} (+#{stats[:submitted_applications_today]})
      *Paid Applications From:* #{state_wise_paid_count}
      *Unique Visits Today:* #{stats[:total_visits_today]}

      <#{dashboard_url}|:bar_chart: View Dashboard>
    MESSAGE
  end

  def state_wise_paid_count
    message = State.focused_for_admissions.each_with_object('') do |state, string|
      count = stats[:state_wise_stats][state.name.to_sym][:paid_applications]
      string << "#{state.name}(#{count}) " if count.positive?
    end

    others_count = stats[:state_wise_stats][:Others][:paid_applications]
    message << "Others(#{others_count})" if others_count.positive?

    message
  end

  def dashboard_url
    Rails.application.routes.url_helpers.admin_admissions_dashboard_url(batch: batch.id)
  end

  def days_passed
    batch.campaign_days_passed
  end

  def total_days
    batch.total_campaign_days
  end

  def days_left
    batch.campaign_days_left
  end

  def target_count
    batch.target_application_count
  end
end

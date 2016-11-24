require 'rails_helper'

describe AdmissionStatsNotificationJob do
  subject { described_class }

  let!(:batch) { create(:batch, :in_stage_1).decorate }
  let!(:state) { create :state, name: 'Kerala' }

  let(:dummy_stats) do
    {
      total_visits_today: 1000,
      paid_applications: 100,
      paid_from_earlier_batches: 20,
      paid_applications_today: 5,
      payment_initiated: 20,
      payment_initiated_today: 3,
      submitted_applications: 200,
      submitted_applications_today: 10,
      top_references_today: [['Friend', 20], ['Event', 15]],
      state_wise_stats: {
        'Kerala': { paid_applications: 2 },
        Others: { paid_applications: 2 }
      }
    }
  end

  let(:dashboard_url) { Rails.application.routes.url_helpers.admin_admissions_dashboard_url(batch: batch.id) }

  let(:admission_stats_summary) do
    <<~MESSAGE
      > Here are the *Admission Campaign Stats for Batch #{batch.batch_number}* today:
      *Campaign Progress:* Day #{batch.campaign_days_passed}/#{batch.total_campaign_days} (#{batch.campaign_days_left} days left)
      *Target Achieved:* 100/#{batch.target_application_count} applications.
      *Payments Completed:* 100 (+5)
      :point_up_2: _Note that 20 of these were moved-in from earlier batches._
      *Payments Intiated:* 20 (+3)
      *Applications Started:* 200 (+10)
      *Paid Applications From:* Kerala (2), Others (2)
      *Top References Today:* Friend(20), Event(15)
      *Unique Visits Today:* 1000

      <#{dashboard_url}|:bar_chart: View Dashboard>
    MESSAGE
  end

  it 'posts the admission stats to Slack' do
    allow(AdmissionStatsService).to receive(:load_stats).with(batch).and_return(dummy_stats)
    expect(RestClient).to receive(:post).with('http://example.com/slack', { 'text': admission_stats_summary }.to_json)
    subject.perform_now
  end
end

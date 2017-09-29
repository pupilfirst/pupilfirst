require 'rails_helper'

describe Founder do
  describe '#activity_timeline' do
    include ActiveSupport::Testing::TimeHelpers

    it 'returns activity count by month and week' do
      # Use this as reference time (replacement for Time.now).
      reference_time = Time.parse 'Tue, 26 Jan 2016 02:00:00 IST +05:30'

      travel_to(reference_time) do
        # Set up the environment.
        startup = create :startup
        founder = startup.founders.first
        founder.update!(created_at: 1.year.ago)

        # Events we expect should be counted in the timeline.
        5.times { create :public_slack_message, founder: founder, created_at: 1.month.ago }
        kp_3_weeks_ago = create :karma_point, founder: founder, created_at: 3.weeks.ago
        te_2_weeks_ago = create :timeline_event, startup: startup, created_at: 2.weeks.ago
        te_1_week_ago = create :timeline_event, startup: startup, created_at: 1.week.ago
        10.times { create :public_slack_message, founder: founder, created_at: 30.minutes.ago }
        kp_now = create :karma_point, founder: founder, created_at: Time.now

        # We won't expect the following events to be counted, since it's outside activity timeline.
        create :timeline_event, startup: startup, created_at: 1.year.ago
        create :public_slack_message, founder: founder, created_at: 2.months.from_now

        # The expected response.
        expected_activity_timeline = {
          'June' => {
            counts: { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
          },
          'July' => {
            counts: { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
          },
          'August' => {
            counts: { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0 }
          },
          'September' => {
            counts: { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
          },
          'October' => {
            counts: { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
          },
          'November' => {
            counts: { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }
          },
          'December' => {
            counts: { 1 => 0, 2 => 0, 3 => 0, 4 => 5, 5 => 0 },
            list: [
              { type: :public_slack_message, count: 5 }
            ]
          },
          'January' => {
            counts: { 1 => 0, 2 => 1, 3 => 1, 4 => 1, 5 => 11, 6 => 0 },
            list: [
              { type: :karma_point, karma_point: kp_3_weeks_ago },
              { type: :timeline_event, timeline_event: te_2_weeks_ago },
              { type: :timeline_event, timeline_event: te_1_week_ago },
              { type: :public_slack_message, count: 10 },
              { type: :karma_point, karma_point: kp_now }
            ]
          }
        }

        expect(founder.activity_timeline).to eq(expected_activity_timeline)
      end
    end
  end
end

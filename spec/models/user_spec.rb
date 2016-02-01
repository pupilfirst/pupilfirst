require 'rails_helper'
require 'webmock/rspec'

describe User do
  context 'non_founders scopes' do
    it 'returns users who are not related to any startup' do
      user = create(:user_with_out_password, startup: nil)
      expect(User.non_founders.map(&:id)).to include(user.id)
    end
  end

  describe '#remove_from_startup!' do
    it 'disassociates a user from startup completely' do
      startup = create :startup
      founder = startup.founders.first
      founder.remove_from_startup!
      founder.reload
      expect(founder.startup).to eq nil
      expect(founder.is_founder).to eq nil
      expect(founder.startup_admin).to eq nil
    end
  end

  context 'Slack integration' do
    before :all do
      APP_CONFIG[:slack_token] = 'xxxxxx'
    end

    after :all do
      APP_CONFIG[:slack_token] = ENV['SLACK_TOKEN']
    end

    before :each do
      stub_request(:get, "https://slack.com/api/users.list?token=xxxxxx")
        .to_return(body: '{"ok":true,"members":[{"id":"UABCDEFGH","name":"slackuser"}]}')
    end

    context 'user updates slack_username to a random name not on public slack' do
      it 'validates absence of username in SV.CO public slack and raises error' do
        user = create :user_with_password
        user.update(slack_username: 'abc')
        expect(a_request(:get, "https://slack.com/api/users.list?token=xxxxxx")).to have_been_made.once
        expect(user.errors[:slack_username]).to include('a user with this mention name does not exist on SV.CO Public Slack')
      end
    end

    context 'user updates slack_username to a valid name on public slack' do
      it 'validates presence of username in SV.CO public slack and updates succesfully' do
        user = create :user_with_password
        user.update(slack_username: 'slackuser')
        expect(a_request(:get, "https://slack.com/api/users.list?token=xxxxxx")).to have_been_made.once
        expect(user.errors[:slack_username]).to be_empty
        expect(user.slack_user_id).to_not be_nil
      end
    end

    context 'user empties slack_username' do
      it 'clears slack_user_id and sends no query to slack' do
        user = create :user_with_password
        user.update(slack_username: '')
        expect(a_request(:get, "https://slack.com/api/users.list?token=xxxxxx")).not_to have_been_made
        expect(user.slack_username).to be_nil
        expect(user.slack_user_id).to be_nil
      end
    end
  end

  describe '#activity_timeline' do
    it 'returns activity count by month and week' do
      # Use this as reference time (replacement for Time.now).
      reference_time = Time.parse 'Tue, 26 Jan 2016 02:00:00 IST +05:30'

      # Set up the environment.
      batch = create :batch, start_date: (reference_time - 3.months), end_date: (reference_time + 1.month)
      startup = create :startup, batch: batch
      user = startup.founders.first

      # Events we expect should be counted in the timeline.
      5.times { create :public_slack_message, user: user, created_at: (reference_time - 1.month) }
      kp_3_weeks_ago = create :karma_point, user: user, created_at: (reference_time - 3.weeks)
      te_2_weeks_ago = create :timeline_event, startup: startup, created_at: (reference_time - 2.weeks)
      te_1_week_ago = create :timeline_event, startup: startup, created_at: (reference_time - 1.week)
      10.times { create :public_slack_message, user: user, created_at: (reference_time - 30.minutes) }
      kp_now = create :karma_point, user: user, created_at: reference_time

      # We won't expect the following events to be counted, since it's outside batch timing.
      create :timeline_event, startup: startup, created_at: (reference_time - 6.months)
      create :public_slack_message, user: user, created_at: (reference_time + 2.months)

      # The expected response.
      expected_activity_timeline = {
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
        },
        'February' => { counts: { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 } }
      }

      expect(user.activity_timeline).to eq(expected_activity_timeline)
    end
  end
end

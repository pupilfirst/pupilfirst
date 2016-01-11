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
      batch = create :batch, start_date: 1.month.ago, end_date: 5.months.from_now
      startup = create :startup, batch: batch
      user = startup.founders.first

      te_now = create :timeline_event, startup: startup
      te_2_weeks_ago = create :timeline_event, startup: startup, created_at: 2.weeks.ago

      10.times { create :public_slack_message, user: user }
      5.times { create :public_slack_message, user: user, created_at: 1.month.ago }

      kp_now = create :karma_point, user: user
      kp_2_weeks_ago = create :karma_point, user: user, created_at: 2.weeks.ago

      # We won't expect the following events to be counted, since it's outside batch timing.
      create :timeline_event, startup: startup, created_at: 3.months.ago
      create :public_slack_message, user: user, created_at: 5.months.from_now

      # Fill out expected activity counts with zero-es first.
      end_date = batch.end_date > Time.now ? Time.now.end_of_month : batch.end_date
      first_day_of_each_month = (batch.start_date.beginning_of_month..end_date).select { |d| d.day == 1 }

      expected_activity = first_day_of_each_month.each_with_object({}) do |first_day_of_month, hash|
        hash[first_day_of_month.strftime('%B')] = { counts: (1..WeekOfMonth.total_weeks(first_day_of_month)).each_with_object({}) { |w, o| o[w] = 0 } }
      end

      # Then fill in expected data:
      expected_activity[1.month.ago.strftime('%B')][:counts][WeekOfMonth.week_of_month(1.month.ago)] = 5
      expected_activity[1.month.ago.strftime('%B')][:list] = [{ type: :public_slack_message, count: 5 }]
      expected_activity[2.weeks.ago.strftime('%B')][:counts][WeekOfMonth.week_of_month(2.weeks.ago)] = 2

      expected_activity[2.weeks.ago.strftime('%B')][:list] ||= []

      expected_activity[2.weeks.ago.strftime('%B')][:list] += [
        { type: :timeline_event, timeline_event: te_2_weeks_ago },
        { type: :karma_point, karma_point: kp_2_weeks_ago }
      ]

      expected_activity[Time.now.strftime('%B')][:counts][WeekOfMonth.week_of_month(Time.now)] = 12

      expected_activity[Time.now.strftime('%B')][:list] ||= []

      expected_activity[Time.now.strftime('%B')][:list] += [
        { type: :timeline_event, timeline_event: te_now },
        { type: :public_slack_message, count: 10 },
        { type: :karma_point, karma_point: kp_now }
      ]

      expect(user.activity_timeline).to eq(expected_activity)
    end
  end
end

require 'rails_helper'

describe VocalistPingJob do
  subject { described_class }

  let!(:startup) { create :startup }
  let!(:founder) { create :founder, startup: startup }

  let(:expected_founder_message) do
    I18n.t(
      'slack_notifications.karma_points.founder',
      points: 10,
      activity_type: Faker::Lorem.sentence
    )
  end

  let(:expected_startup_message) do
    I18n.t(
      'slack_notifications.karma_points.startup',
      points: 20,
      startup_url: Rails.application.routes.url_helpers.startup_url(startup),
      startup_product_name: startup.product_name,
      activity_type: Faker::Lorem.sentence
    )
  end

  let(:founders) do
    { founders: startup.founders.pluck(:id) }
  end

  describe '#perform' do
    it 'sends slack notification to a founder on the karma points awarded to him for Founder
    target/Slack Activity/Platform Feedback' do
      expect_any_instance_of(PublicSlack::MessageService).to receive(:execute).with(message: expected_founder_message, founder: founder)
      subject.perform_now(expected_founder_message, founder: founder)
    end

    it 'sends slack notification to all founders in a startup for the karma points awarded
    for Startup targets/Timeline Events/Connect Requests' do
      expect_any_instance_of(PublicSlack::MessageService).to receive(:execute).with(message: expected_startup_message, founders: startup.founders)
      subject.perform_now(expected_startup_message, founders)
    end
  end
end

require 'rails_helper'

describe VocalistPingJob do
  subject { described_class }

  let!(:startup) { create :startup }
  let!(:founder) { create :founder, startup: startup }

  let(:expected_founder_message) do
    I18n.t(
      'services.karma_points.create.founder_slack_notification',
      points: 10,
      activity_type: Faker::Lorem.sentence
    )
  end

  let(:expected_startup_message) do
    I18n.t(
      'services.karma_points.create.startup_slack_notification',
      points: 20,
      startup_url: Rails.application.routes.url_helpers.startup_url(startup),
      startup_product_name: startup.product_name,
      activity_type: Faker::Lorem.sentence
    )
  end

  let(:founders) do
    { founders: startup.founders.pluck(:id) }
  end

  let(:mock_message_service) { instance_double(PublicSlack::MessageService) }

  describe '#perform' do
    it 'sends slack notification to a founder on the karma points awarded to him for Founder
    target/Slack Activity/Platform Feedback' do
      expect(PublicSlack::MessageService).to receive(:new).and_return(mock_message_service)
      expect(mock_message_service).to receive(:post).with(message: expected_founder_message, founder: founder)
      subject.perform_now(expected_founder_message, founder: founder)
    end

    it 'sends slack notification to all founders in a startup for the karma points awarded
    for Startup targets/Timeline Events/Connect Requests' do
      expect(PublicSlack::MessageService).to receive(:new).and_return(mock_message_service)
      expect(mock_message_service).to receive(:post).with(message: expected_startup_message, founders: startup.founders)
      subject.perform_now(expected_startup_message, founders)
    end
  end
end

require 'rails_helper'

describe VocalistPingJob do
  subject { described_class }

  let!(:startup) { create :startup }
  let!(:founder) { create :founder, startup: startup }
  let(:expected_founder_message) { Faker::Lorem.sentence }
  let(:expected_startup_message) { Faker::Lorem.sentence }

  let(:founders) do
    { founders: startup.founders.pluck(:id) }
  end

  let(:mock_message_service) { instance_double(PublicSlack::MessageService) }

  describe '#perform' do
    it 'can send slack notification to a founder' do
      expect(PublicSlack::MessageService).to receive(:new).and_return(mock_message_service)
      expect(mock_message_service).to receive(:post).with(message: expected_founder_message, founder: founder)
      subject.perform_now(expected_founder_message, founder: founder)
    end

    it 'can sends slack notification to all founders in a startup' do
      expect(PublicSlack::MessageService).to receive(:new).and_return(mock_message_service)
      expect(mock_message_service).to receive(:post).with(message: expected_startup_message, founders: startup.founders)
      subject.perform_now(expected_startup_message, founders)
    end
  end
end

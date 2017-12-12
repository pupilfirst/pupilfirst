require 'rails_helper'

describe Targets::SendSessionRemindersJob do
  subject { described_class }

  def time_delta(session)
    "#{((session.session_at - Time.zone.now) / 60).round} minutes"
  end

  def time_exact(session)
    session.session_at.strftime('%l:%M %p')
  end

  let(:level_1) { create :level, :one }
  let(:level_2) { create :level, :two }
  let(:level_3) { create :level, :three }

  let!(:startup_l1) { create :startup, :subscription_active, level: level_1 }
  let!(:startup_l2) { create :startup, :subscription_active, level: level_2 }
  let!(:startup_l2_inactive) { create :startup, level: level_2 }
  let!(:startup_l3) { create :startup, :subscription_active, level: level_3 }

  let!(:session_imminent) { create :target, :session, session_at: 30.minutes.from_now, level: level_2 }
  let!(:session_not_imminent) { create :target, :session, session_at: 1.hour.from_now }

  let(:service_response) { double('Message Service Response', errors: {}) }
  let(:message_service) { instance_double(PublicSlack::MessageService, post: service_response) }

  let(:expected_message) { "Reminder: \"#{session_imminent.title}\" will start in #{time_delta(session_imminent)} (at #{time_exact(session_imminent)}). Please check the Slack collective channel for the link to join session." }

  before do
    allow(PublicSlack::MessageService).to receive(:new).and_return(message_service)
  end

  describe '#perform' do
    it 'sends slack messages for imminent sessions to the appropriate founders' do
      # Founders in session's level and above should get notifications.
      Founder.where(startup: [startup_l2, startup_l3]).each do |founder|
        expect(message_service).to receive(:post).with(message: expected_message, founder: founder)
      end

      # Founders below session's level, or without active subscription should not receive notifications.
      Founder.where(startup: [startup_l1, startup_l2_inactive]).each do |founder|
        expect(message_service).not_to receive(:post).with(message: expected_message, founder: founder)
      end

      subject.perform_now
    end

    it 'sets slack_reminders_sent_at for processed sessions' do
      expect { subject.perform_now }.to change { session_imminent.reload.slack_reminders_sent_at }.from(nil).to be_a(ActiveSupport::TimeWithZone)
      expect(session_not_imminent.reload.slack_reminders_sent_at).to eq(nil)
    end

    context 'when slack_reminders_sent_at is already set' do
      before do
        session_imminent.update!(slack_reminders_sent_at: 1.minute.ago)
      end

      it 'does not send slack messages for imminent session' do
        Founder.where(startup: [startup_l2, startup_l3]).each do |founder|
          expect(message_service).not_to receive(:post).with(message: expected_message, founder: founder)
        end

        subject.perform_now
      end
    end
  end
end

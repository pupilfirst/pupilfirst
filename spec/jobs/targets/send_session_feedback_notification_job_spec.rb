require 'rails_helper'

describe Targets::SendSessionFeedbackNotificationJob do
  subject { described_class }

  let!(:session_recent) { create :target, :session, session_at: 70.minutes.ago }
  let!(:session_old) { create :target, :session, session_at: 2.days.ago }

  let(:service_response) { double('Message Service Response', errors: {}) }
  let(:message_service) { instance_double(PublicSlack::MessageService, post: service_response) }

  let(:expected_message) do
    faculty_name = session_recent.faculty.name

    <<~EXPECTED_MESSAGE
      Hello there! Thank you to all who attended today's live session by #{faculty_name}.

      We hope that you found the session informative and worthwhile.

      If you missed watching it live, we will have it up on the dashboard in a couple of days.

      Kindly help us improve our sessions with some quick feedback: https://svlabs.typeform.com/to/h7g9Om?faculty=#{URI.escape(faculty_name)}&session=#{URI.escape(session_recent.title)}&date=#{URI.escape(session_recent.session_at.strftime('%Y-%m-%d'))}
    EXPECTED_MESSAGE
  end

  before do
    allow(PublicSlack::MessageService).to receive(:new).and_return(message_service)
  end

  describe '#perform' do
    it 'sends slack messages for recently completed sessions to the #collective channel' do
      # #collective channel should receive a feedback request for recently completed session.
      # #collective channel should not receive a feedback request for old completed session.
      expect(message_service).to receive(:post).with(message: expected_message, channel: '#collective')

      subject.perform_now
    end

    it 'sets feedback_asked_at of session for which feedback was asked' do
      expect { subject.perform_now }.to change { session_recent.reload.feedback_asked_at }.from(nil).to be_a(ActiveSupport::TimeWithZone)

      # and does not touch the value of other sessions.
      expect(session_old.reload.feedback_asked_at).to eq(nil)
    end

    context 'when slack_reminders_sent_at is already set' do
      before do
        session_recent.update!(feedback_asked_at: 1.minute.ago)
      end

      it 'does not send slack messages for imminent session' do
        expect(message_service).not_to receive(:post).with(message: expected_message, channel: '#collective')

        subject.perform_now
      end
    end
  end
end

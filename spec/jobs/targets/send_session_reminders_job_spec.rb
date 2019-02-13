require 'rails_helper'

describe Targets::SendSessionRemindersJob do
  subject { described_class }

  def time_delta(session)
    "#{((session.session_at - Time.zone.now) / 60).round} minutes"
  end

  def time_exact(session)
    session.session_at.strftime('%l:%M %p')
  end

  def build_expected_message(session_imminent)
    "Reminder: \"#{session_imminent.title}\" will start in #{time_delta(session_imminent)} (at #{time_exact(session_imminent)}). Please check the Slack collective channel for the link to join session."
  end

  let(:course_1) { create :course }
  let(:course_2) { create :course }

  let(:level_1) { create :level, :one, course: course_1 }
  let(:level_2) { create :level, :two, course: course_1 }
  let(:level_3) { create :level, :three, course: course_1 }
  let(:level_1_s2) { create :level, :one, course: course_2 }
  let(:level_2_s2) { create :level, :two, course: course_2 }
  let(:level_3_s2) { create :level, :three, course: course_2 }

  let!(:startup_l1) { create :startup, level: level_1 }
  let!(:startup_l2) { create :startup, level: level_2 }
  let!(:startup_l3) { create :startup, level: level_3 }
  let!(:startup_s2_l1) { create :startup, level: level_1_s2 }
  let!(:startup_s2_l2) { create :startup, level: level_2_s2 }
  let!(:startup_s2_l3) { create :startup, level: level_3_s2 }

  let(:l2_target_group) { create :target_group, level: level_2 }
  let(:s2_l2_target_group) { create :target_group, level: level_2_s2 }

  let!(:s1_session_not_imminent) { create :target, :session, session_at: 1.hour.from_now, target_group: l2_target_group }

  let(:service_response) { double('Message Service Response', errors: {}) }
  let(:message_service) { instance_double(PublicSlack::MessageService, post: service_response) }

  before do
    allow(PublicSlack::MessageService).to receive(:new).and_return(message_service)
  end

  describe '#perform' do
    let(:expected_message) { build_expected_message(session_imminent) }

    context 'when a session is imminenet for startups' do
      let!(:session_imminent) { create :target, :session, session_at: 30.minutes.from_now, target_group: l2_target_group }

      it 'sends slack messages for imminent sessions to the appropriate founders' do
        # Founders in session's level and above should get notifications.
        Founder.where(startup: [startup_l2, startup_l3]).each do |founder|
          expect(message_service).to receive(:post).with(message: expected_message, founder: founder)
        end

        # Founders below session's level should not receive notifications.
        Founder.where(startup: [startup_l1]).each do |founder|
          expect(message_service).not_to receive(:post).with(message: expected_message, founder: founder)
        end

        # Founders in other courses should not receive notifications.
        Founder.where(startup: [startup_s2_l1, startup_s2_l2, startup_s2_l3]).each do |founder|
          expect(message_service).not_to receive(:post).with(message: expected_message, founder: founder)
        end

        subject.perform_now
      end

      it 'sets slack_reminders_sent_at for processed sessions' do
        expect { subject.perform_now }.to change { session_imminent.reload.slack_reminders_sent_at }.from(nil).to be_a(ActiveSupport::TimeWithZone)
        expect(s1_session_not_imminent.reload.slack_reminders_sent_at).to eq(nil)
      end
    end

    context 'when slack_reminders_sent_at is already set' do
      let!(:session_imminent) { create :target, :session, session_at: 30.minutes.from_now, target_group: l2_target_group, slack_reminders_sent_at: 1.minute.ago }

      it 'does not send slack messages for imminent session' do
        Founder.where(startup: [startup_l2, startup_l3]).each do |founder|
          expect(message_service).not_to receive(:post).with(message: expected_message, founder: founder)
        end

        subject.perform_now
      end
    end
  end
end

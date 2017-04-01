require 'rails_helper'

describe Users::ConfirmationService do
  subject { described_class }

  let(:startup) { create :startup }
  let(:founder) { startup.admin }
  let(:user) { founder.user }

  context 'when user is signing in for the first time' do
    it 'sets confirmed_at for user' do
      expect do
        subject.new(user).execute
      end.to change { user.reload.confirmed_at }.from(nil)
    end

    it 'creates timeline event entry for founder' do
      expect do
        subject.new(user).execute
      end.to change(TimelineEvent, :count).by(1)

      last_timeline_event = TimelineEvent.last

      expect(last_timeline_event.target.key).to eq(Target::KEY_ADMISSIONS_FOUNDER_EMAIL_VERIFICATION)
      expect(last_timeline_event.timeline_event_type.key).to eq(TimelineEventType::TYPE_FOUNDER_UPDATE)
    end
  end

  context 'when user is not signing in for the first time' do
    before do
      user.update!(confirmed_at: Time.zone.now)
    end

    it 'does not update confirmed_at' do
      expect do
        subject.new(user).execute
      end.to_not change { user.reload.confirmed_at }
    end

    it 'does not create timeline event' do
      expect do
        subject.new(user).execute
      end.to_not change(TimelineEvent, :count)
    end
  end
end

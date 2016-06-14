require 'rails_helper'

describe FacultyConnectSessionReminderJob do
  subject { described_class }

  context 'when the job is no longer relevant' do
    let(:connect_request) { create :connect_request, status: ConnectRequest::STATUS_REQUESTED }

    it 'does nothing' do
      expect(PublicSlackTalk).to_not receive(:post_message)

      subject.perform_now connect_request.id
    end
  end

  context 'when the job is still relevant' do
    let(:connect_slot) { create :connect_slot, slot_at: 20.minutes.from_now }
    let(:connect_request) { create :connect_request, status: ConnectRequest::STATUS_CONFIRMED, connect_slot: connect_slot }

    it 'notifies the faculty, founders and ops team on slack' do
      expect(PublicSlackTalk).to receive(:post_message).with(message: instance_of(String), founders: connect_request.startup.founders)
      expect(PublicSlackTalk).to receive(:post_message).with(message: instance_of(String), founder: connect_request.faculty)
      expect(PublicSlackTalk).to receive(:post_message).with(message: instance_of(String), founders: Faculty.ops_team)

      subject.perform_now connect_request.id
    end
  end
end

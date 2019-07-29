require 'rails_helper'

describe FacultyConnectSessionReminderJob do
  subject { described_class }

  before do
    create :domain, :primary, school: connect_request.startup.school
  end

  context 'when the job is no longer relevant' do
    let(:connect_request) { create :connect_request, status: ConnectRequest::STATUS_REQUESTED }

    it 'does nothing' do
      expect_any_instance_of(PublicSlack::MessageService).to_not receive(:post)

      subject.perform_now connect_request.id
    end
  end

  context 'when the job is still relevant' do
    let(:connect_slot) { create :connect_slot, slot_at: 20.minutes.from_now }
    let(:connect_request) { create :connect_request, status: ConnectRequest::STATUS_CONFIRMED, connect_slot: connect_slot }
    let(:mock_message_service) { instance_double PublicSlack::MessageService }

    it 'notifies the faculty, founders and ops team on slack' do
      expect(PublicSlack::MessageService).to receive(:new).and_return(mock_message_service)
      expect(mock_message_service).to receive(:post).with(message: instance_of(String), founders: connect_request.startup.founders)
      expect(mock_message_service).to receive(:post).with(message: instance_of(String), founder: connect_request.faculty)

      subject.perform_now connect_request.id
    end
  end
end

require 'rails_helper'

describe ConnectRequests::ConfirmationService do
  subject { described_class.new(connect_request) }

  let!(:connect_request) { create :connect_request, status: ConnectRequest::STATUS_REQUESTED }

  describe '#execute' do
    let(:faculty_mailer) { double FacultyMailer }
    let(:startup_mailer) { double StartupMailer }
    let(:mock_calendar_service) { instance_double ConnectRequests::CreateCalendarEventService, execute: nil }
    let(:mock_create_faculty_connect_service) { instance_double Zoom::CreateFacultyConnectService }
    let(:meeting_url) { Faker::Internet.url }

    it 'sends mail for confirmed, saves confirmation time, sets up google calendar event and creates rating/reminder jobs' do
      expect(FacultyMailer).to receive(:connect_request_confirmed).with(connect_request).and_return(faculty_mailer)
      expect(StartupMailer).to receive(:connect_request_confirmed).with(connect_request).and_return(startup_mailer)
      expect(faculty_mailer).to receive(:deliver_later)
      expect(startup_mailer).to receive(:deliver_later)

      expect(ConnectRequests::CreateCalendarEventService).to receive(:new).with(connect_request).and_return(mock_calendar_service)
      expect(Zoom::CreateFacultyConnectService).to receive(:new).with(connect_request).and_return(mock_create_faculty_connect_service)
      expect(mock_create_faculty_connect_service).to receive(:create).and_return('join_url' => meeting_url)

      subject.execute

      expect(FacultyConnectSessionRatingJob).to have_been_enqueued.with(connect_request.id)
        .at(a_value_within(5.seconds).of(connect_request.connect_slot.slot_at + 45.minutes))

      expect(FacultyConnectSessionReminderJob).to have_been_enqueued.with(connect_request.id)
        .at(a_value_within(5.seconds).of(connect_request.connect_slot.slot_at - 30.minutes))

      expect(connect_request.reload.confirmed_at).to_not be_nil
      expect(connect_request).to have_attributes(status: ConnectRequest::STATUS_CONFIRMED, meeting_link: meeting_url)
    end
  end
end

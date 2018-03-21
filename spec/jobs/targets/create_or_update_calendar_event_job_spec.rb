require 'rails_helper'

describe Targets::CreateOrUpdateCalendarEventJob do
  subject { described_class }

  before(:all) do
    described_class.active = true
  end

  after(:all) do
    described_class.active = false
  end

  def founder_details(founder)
    {
      'email' => founder.email,
      'displayName' => founder.fullname,
      'responseStatus' => 'needsAction'
    }
  end

  let(:admin_user) { create :admin_user }
  let(:level_one) { create :level, :one }
  let(:level_two) { create :level, :two }
  let(:level_three) { create :level, :three }
  let!(:startup_l1) { create :startup, :subscription_active, level: level_one }
  let!(:startup_inactive_l2) { create :startup, level: level_two }
  let!(:startup_l2) { create :startup, :subscription_active, level: level_two }
  let!(:startup_l3) { create :startup, :subscription_active, level: level_three }
  let!(:target_group) { create :target_group, level: level_two, milestone: true }
  let!(:target) { create :target, session_at: 1.week.from_now, target_group: target_group }
  let(:calendar_service) { instance_double(GoogleCalendarService) }
  let(:null_calendar_event) { double('Google Calendar Event', html_link: calendar_event_link).as_null_object }
  let(:calendar_event) { double 'Google Calendar Event', id: calendar_event_id, html_link: calendar_event_link }
  let(:calendar_event_id) { rand(100_000).to_s }
  let(:calendar_event_link) { Faker::Internet.url }

  let(:expected_attendees) do
    attendees = startup_l2.founders.map { |f| founder_details(f) }
    attendees + startup_l3.founders.map { |f| founder_details(f) }
  end

  before do
    allow(GoogleCalendarService).to receive(:new).and_return(calendar_service)
  end

  describe '#execute' do
    it 'creates invitation with relevant details for founders with access to session' do
      expect(calendar_service).to receive(:find_or_create_event_by_id).with(nil).and_yield(calendar_event).and_return(calendar_event)
      expect(calendar_event).to receive(:title=).with("SV.CO Live Session: #{target.title}")
      expect(calendar_event).to receive(:start_time=).with(target.session_at.iso8601)
      expect(calendar_event).to receive(:end_time=).with((target.session_at + 30.minutes).iso8601)
      expect(calendar_event).to receive(:attendees=).with(a_collection_containing_exactly(*expected_attendees))
      expect(calendar_event).to receive(:description=).with(I18n.t("services.targets.create_or_update_calendar_event.description"))
      expect(calendar_event).to receive(:guests_can_invite_others=).with(false)
      expect(calendar_event).to receive(:guests_can_see_other_guests=).with(false)
      expect(calendar_event).to receive(:send_notifications=).with(true)

      expect(calendar_event).to receive(:reminders=).with(
        'useDefault' => false,
        'overrides' => [
          { 'method' => 'popup', 'minutes' => 30 },
          { 'method' => 'popup', 'minutes' => 10 }
        ]
      )

      subject.perform_now(target, admin_user)
    end

    it 'stores the Google calendar event ID with target' do
      allow(calendar_service).to receive(:find_or_create_event_by_id).and_yield(null_calendar_event).and_return(calendar_event)

      subject.perform_now(target, admin_user)

      expect(target.reload.google_calendar_event_id).to eq(calendar_event_id)
    end

    it 'sends an email to admin user informing him of completion' do
      allow(calendar_service).to receive(:find_or_create_event_by_id).and_yield(null_calendar_event).and_return(calendar_event)

      subject.perform_now(target, admin_user)

      open_email(admin_user.email)

      expect(current_email).to have_content('Google Calendar Invitations Sent')
    end

    context 'when an event with invitation already exists' do
      let!(:target) { create :target, session_at: 1.week.from_now, target_group: target_group, google_calendar_event_id: calendar_event_id }

      it 'updates the existing calendar event' do
        expect(calendar_service).to receive(:find_or_create_event_by_id).with(calendar_event_id).and_yield(null_calendar_event).and_return(null_calendar_event)

        subject.perform_now(target, admin_user)
      end
    end
  end
end

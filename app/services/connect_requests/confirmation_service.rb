module ConnectRequests
  class ConfirmationService
    def initialize(connect_request)
      @connect_request = connect_request
    end

    def execute
      ConnectRequest.transaction do
        # Create a meeting at Zoom and get the meeting link.
        zoom_meeting = Zoom::CreateFacultyConnectService.new(@connect_request).create
        meeting_link = zoom_meeting&.dig('join_url')

        # Save the meeting link & set status and confirmed_at.
        @connect_request.update!(
          meeting_link: meeting_link,
          status: ConnectRequest::STATUS_CONFIRMED,
          confirmed_at: Time.zone.now
        )

        # Create Google calendar entry with the meeting_link pre-filled.
        ConnectRequests::CreateCalendarEventService.new(@connect_request).execute

        # Email confirmation to all attendees.
        FacultyMailer.connect_request_confirmed(@connect_request).deliver_later
        StartupMailer.connect_request_confirmed(@connect_request).deliver_later

        # Schedule reminder and rating jobs.
        FacultyConnectSessionReminderJob.set(wait_until: connect_slot.slot_at - 30.minutes).perform_later(@connect_request.id)
        FacultyConnectSessionRatingJob.set(wait_until: connect_slot.slot_at + 45.minutes).perform_later(@connect_request.id)
      end
    end

    private

    def connect_slot
      @connect_slot ||= @connect_request.connect_slot
    end
  end
end

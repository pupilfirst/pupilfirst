module ConnectRequests
  class CreateCalendarEventService
    def initialize(connect_request)
      @connect_request = connect_request
      @google_calendar = GoogleCalendarService.new if Rails.env.production?
    end

    def execute
      return unless Rails.env.production?

      @google_calendar.create_event do |e|
        e.title = calendar_event_title
        e.start_time = @connect_request.slot_at.iso8601
        e.end_time = (@connect_request.slot_at + ConnectRequest::MEETING_DURATION).iso8601
        e.attendees = attendees
        e.description = calendar_event_description
        e.guests_can_invite_others = false
        e.guests_can_see_other_guests = false
        e.location = @connect_request.meeting_link
        e.send_notifications = true

        # Default visibility should be sufficient since it equals calendar's setting.
        # e.visibility = 'public'

        # Send an SMS one day before the office hour and a pop-up message one hour before.
        e.reminders = {
          'useDefault' => false, 'overrides' => [
            { 'method' => 'popup', 'minutes' => 60 },
            { 'method' => 'sms', 'minutes' => (24 * 60) }
          ]
        }
      end
    end

    private

    delegate :startup, :faculty, :questions, to: :@connect_request

    def calendar_event_title
      "#{startup.name} / #{faculty.name} (Office Hour)"
    end

    def calendar_event_description
      <<~DESCRIPTION
        Student: #{@founder.fullname}
        Timeline: #{Rails.application.routes.url_helpers.student_url(@founder.id, host: 'https://www.sv.co')}

        Questions Asked:

        #{questions.delete("\r").to_json[1..-2]}
      DESCRIPTION
    end

    def founder
      @founder ||= @connect_request.startup.founders.first
    end

    def attendees
      list = [{ 'email' => faculty.email, 'displayName' => faculty.name, 'responseStatus' => 'needsAction' }]

      list + (startup.founders.map do |founder|
        {
          'email' => founder.email,
          'displayName' => founder.fullname,
          'responseStatus' => 'needsAction'
        }
      end)
    end
  end
end

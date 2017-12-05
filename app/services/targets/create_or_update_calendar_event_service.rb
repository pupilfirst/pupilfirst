module Targets
  # Create or update Google Calendar event.
  class CreateOrUpdateCalendarEventService
    def initialize(target)
      @target = target
      @google_calendar = GoogleCalendarService.new if Rails.env.production?
    end

    def execute
      return unless Rails.env.production?

      event = @google_calendar.find_or_create_event_by_id(@target.google_calendar_event_id) do |e|
        add_event_details(e)
      end

      # Save the event ID if the event was newly created.
      @target.update!(google_calendar_event_id: event.id) if @target.google_calendar_event_id.blank?
    end

    private

    delegate :startup, :faculty, :questions, to: :@target

    def add_event_details(event)
      event.title = calendar_event_title
      event.start_time = @target.session_at.iso8601
      event.end_time = (@target.session_at + 1.hour).iso8601
      event.attendees = attendees
      event.description = calendar_event_description
      event.guests_can_invite_others = false
      event.guests_can_see_other_guests = false

      # Default visibility should be sufficient since it equals calendar's setting.
      # event.visibility = 'public'

      # Send SMSs one day before, and a pop-up messages 30 minutes and 10 minutes prior to session.
      event.reminders = {
        'useDefault' => false, 'overrides' => [
          { 'method' => 'popup', 'minutes' => 30 },
          { 'method' => 'popup', 'minutes' => 10 },
          { 'method' => 'sms', 'minutes' => (24 * 60) }
        ]
      }
    end

    def calendar_event_title
      "#{startup.product_name} / #{faculty.name} (Faculty Connect)"
    end

    def calendar_event_description
      <<~DESCRIPTION
        Product: #{startup.display_name}
        Timeline: #{Rails.application.routes.url_helpers.timeline_url(startup.id, startup.slug, host: 'https://www.sv.co')}
        Team lead: #{startup.team_lead.fullname}

        Questions Asked:

        #{questions.delete("\r").to_json[1..-2]}
      DESCRIPTION
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

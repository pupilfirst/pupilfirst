module Targets
  # Create or update Google Calendar event.
  class CreateOrUpdateCalendarEventService
    def initialize(target, mock: true)
      @target = target
      @mock = Rails.env.production? ? false : mock
      @google_calendar = GoogleCalendarService.new unless @mock
    end

    def execute
      return if @mock

      event = @google_calendar.find_or_create_event_by_id(@target.google_calendar_event_id) do |e|
        add_event_details(e)
      end

      # Save the event ID if the event was newly created.
      @target.update!(google_calendar_event_id: event.id) if @target.google_calendar_event_id.blank?
    end

    private

    delegate :faculty, to: :@target

    def add_event_details(event)
      event.title = I18n.t("services.targets.create_or_update_calendar_event.title", name: faculty.name, title: faculty.title)
      event.start_time = @target.session_at.iso8601
      event.end_time = (@target.session_at + 30.minutes).iso8601
      event.attendees = attendees
      event.description = I18n.t("services.targets.create_or_update_calendar_event.description")
      event.guests_can_invite_others = false
      event.guests_can_see_other_guests = false

      # Default visibility should be sufficient since it equals calendar's setting.
      # event.visibility = 'public'

      # Send SMSs one day before, and a pop-up messages 30 minutes and 10 minutes prior to session.
      event.reminders = {
        'useDefault' => false, 'overrides' => [
          { 'method' => 'popup', 'minutes' => 30 },
          { 'method' => 'popup', 'minutes' => 10 }
        ]
      }
    end

    def attendees
      Founder.subscribed.at_or_above_level(@target.level).distinct.map do |founder|
        {
          'email' => founder.email,
          'displayName' => founder.name,
          'responseStatus' => 'needsAction'
        }
      end
    end
  end
end

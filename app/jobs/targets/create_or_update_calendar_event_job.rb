module Targets
  # Create or update Google Calendar event.
  class CreateOrUpdateCalendarEventJob < ApplicationJob
    class << self
      attr_accessor :active
    end

    def perform(target, admin_user)
      return unless activated?

      event = GoogleCalendarService.new.find_or_create_event_by_id(target.google_calendar_event_id) do |e|
        add_event_details(e, target)
      end

      # Save the event ID if the event was newly created.
      target.update!(google_calendar_event_id: event.id) if target.google_calendar_event_id.blank?

      # Email admin user that invitations have been created / updated.
      AdminUserMailer.google_calendar_invite_success(admin_user, target, event.html_link).deliver_later
    end

    private

    def activated?
      return true if Rails.env.production?

      !!CreateOrUpdateCalendarEventJob.active
    end

    def add_event_details(event, target)
      event.title = I18n.t("services.targets.create_or_update_calendar_event.title", title: target.title)
      event.start_time = target.session_at.iso8601
      event.end_time = (target.session_at + 30.minutes).iso8601
      event.attendees = attendees(target)
      event.description = I18n.t("services.targets.create_or_update_calendar_event.description")
      event.guests_can_invite_others = false
      event.guests_can_see_other_guests = false
      event.send_notifications = true

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

    # The startups to which calender events should be sent are the ones belonging to the target's course
    # and those at or above the session's minimum level.
    def attendees(target)
      course = target.course
      eligible_levels = course.levels.where('levels.number >= ?', target.level.number)
      applicable_startups = Startup.where(level: eligible_levels)

      (applicable_startups.distinct.map do |startup|
        startup.founders.map do |founder|
          {
            'email' => founder.email,
            'displayName' => founder.name,
            'responseStatus' => 'needsAction'
          }
        end
      end - [nil]).flatten
    end
  end
end

module Targets
  class SendSessionRemindersJob < ApplicationJob
    include Loggable

    queue_as :low_priority

    def perform
      log 'Checking for reminders to be sent for imminent sessions.'

      Target.sessions.where(session_at: (Time.now..35.minutes.from_now)).each do |session|
        next if session.slack_reminders_sent_at.present?

        # Send reminders via Slack to all founders to whom session is applicable.
        send_slack_reminders_to_founder(session)

        # Update time at which reminders were sent.
        session.slack_reminders_sent_at = Time.zone.now
        session.save!
      end
    end

    private

    def send_slack_reminders_to_founder(session)
      log "Sending messages to founders for Session ##{session.id}, occurring at #{session.session_at.iso8601}"

      message_service = PublicSlack::MessageService.new
      service_errors = []

      # Send messages to all founders notifying them that session starts in under 30 minutes.
      Founder.subscribed.at_or_above_level(session.level).distinct.each do |founder|
        response = message_service.post(message: message(session), founder: founder)
        service_errors << response.errors if response.errors.any?

        # Sleep a short while between pings to avoid exceeding Slack's API burst limit.
        sleep 0.2
      end

      log "All messages sent. Errors reported by message_service: #{service_errors}"
    end

    def message(session)
      time_delta = "#{((session.session_at - Time.zone.now) / 60).round} minutes"
      time_exact = session.session_at.strftime('%l:%M %p')

      I18n.t(
        'jobs.targets.send_session_reminders.message',
        title: session.title,
        time_delta: time_delta,
        time_exact: time_exact
      )
    end
  end
end

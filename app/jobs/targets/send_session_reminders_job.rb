module Targets
  class SendSessionRemindersJob < ApplicationJob
    include Loggable

    queue_as :low_priority

    def perform
      log 'Checking for reminders to be sent for imminent sessions.'

      Target.sessions.live.where(session_at: (Time.now..35.minutes.from_now)).each do |session|
        next if session.slack_reminders_sent_at.present?

        # Update time at which reminders were sent, to avoid repeats.
        session.update!(slack_reminders_sent_at: Time.zone.now)

        # Send reminders via Slack to all founders to whom session is applicable.
        send_slack_reminder_to_founders(session)
      end
    end

    private

    def send_slack_reminder_to_founders(session)
      log "Sending messages to founders for Session ##{session.id}, occurring at #{session.session_at.iso8601}"

      message_service = PublicSlack::MessageService.new
      service_errors = []

      # The startups to which reminders for this session should be sent are the ones belonging to the session's course
      # and those at or above the session's minimum level.
      session_level = session.target_group.level
      course = session_level.course
      eligible_levels = course.levels.where('levels.number >= ?', session_level.number)
      applicable_startups = Startup.where(level: eligible_levels)

      applicable_startups.distinct.each do |startup|
        startup.founders.each do |founder|
          response = message_service.post(message: message(session), founder: founder)
          service_errors << response.errors if response.errors.any?

          # Sleep a short while between pings to avoid exceeding Slack's API burst limit.
          sleep 0.2 unless Rails.env.test?
        end
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

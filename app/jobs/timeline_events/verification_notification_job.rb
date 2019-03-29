module TimelineEvents
  class VerificationNotificationJob < ApplicationJob
    queue_as :default

    SLACK_CHANNEL = -'#firehose'

    def perform(timeline_event)
      # few common attributes
      @timeline_event = timeline_event
      @startup = @timeline_event.startup

      @startup_url = Rails.application.routes.url_helpers.product_url(@startup.id, @startup.slug)

      # return if invoked for a pending event - Pending events have no associated notifications, yet
      return if @timeline_event.pending?

      # send message to the founder who submitted the event for both founder and startup targets.
      send_founder_message
      # send notification to the all the founders in a team except the founder who submitted the event.
      send_team_message
      # send event verification message to public slack channel for startup targets.
      send_public_message
    end

    private

    def public_slack_message_service
      @public_slack_message_service ||= PublicSlack::MessageService.new
    end

    def send_founder_message
      target = { founder: @timeline_event.founder }

      slack_message = message('founder', event_status, event_type: event_type)
      public_slack_message_service.post({ message: slack_message }.merge(target))
    end

    def send_team_message
      return if @timeline_event.founder_event?

      target = { founders: (@timeline_event.startup&.founders || []) - [@timeline_event.founder] }

      slack_message = message('team', event_status)

      public_slack_message_service.post({ message: slack_message }.merge(target))
    end

    def send_public_message
      return if @timeline_event.founder_event? || @timeline_event.not_accepted?

      target = { channel: SLACK_CHANNEL }

      slack_message = message('public', event_status)

      public_slack_message_service.post({ message: slack_message }.merge(target))
    end

    def event_type
      @timeline_event.founder_event? ? 'founder_event' : 'startup_event'
    end

    def event_status
      if @timeline_event.verified?
        'verified'
      elsif @timeline_event.needs_improvement?
        'needs_improvement'
      else
        'not_accepted'
      end
    end

    def message(target, status, event_type: nil)
      if target == 'founder'
        I18n.t("jobs.timeline_events.verification_notification.#{target}.#{status}.#{event_type}", message_params)
      else
        I18n.t("jobs.timeline_events.verification_notification.#{target}.#{status}", message_params)
      end
    end

    def message_params
      {
        startup_url: @startup_url,
        startup_name: @startup.name,
        event_url: @timeline_event.share_url,
        event_title: @timeline_event.title,
        event_description: @timeline_event.description,
        links_attached_notice: links_attached_notice
      }
    end

    def links_attached_notice
      return '' unless @timeline_event.public_link?

      notice = "*Public Links attached:*\n"

      @timeline_event.links.each.with_index(1) do |link, index|
        next if link[:private]

        shortened_url = ShortenedUrls::ShortenService.new(link[:url]).shortened_url
        notice += "#{index}. <https://sv.co/r/#{shortened_url.unique_key}|#{link[:title]}>\n"
      end

      notice
    end
  end
end

class TimelineEventVerificationNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(timeline_event)
    # few common attributes
    @timeline_event = timeline_event
    @startup = @timeline_event.startup
    @startup_url = Rails.application.routes.url_helpers.startup_url(@startup)
    @timeline_event_url = @startup_url + "#event-#{@timeline_event.id}"

    # return unless invoked for a verified or needs_improvement event
    return unless @timeline_event.verified? || @timeline_event.needs_improvement?

    # decide the appropriate channel to ping - private ping for founder events, general channel for team events
    target = @timeline_event.founder_event? ? { founder: @timeline_event.founder } : { channel: '#general' }

    # ping appropriate message on slack
    PublicSlackTalk.post_message({ message: slack_notice }.merge(target))
  end

  private

  # form appropriate slack message
  def slack_notice
    if @timeline_event.founder_event?
      @timeline_event.verified? ? private_verification_notice : private_needs_improvement_notice
    else
      @timeline_event.verified? ? public_verification_notice : public_needs_improvement_notice
    end
  end

  def private_verification_notice
    I18n.t "slack_notifications.timeline_events.verification.private", event_title: @timeline_event.title, event_url: @timeline_event_url
  end

  def private_needs_improvement_notice
    I18n.t "slack_notifications.timeline_events.needs_improvement.private", event_title: @timeline_event.title, event_url: @timeline_event_url
  end

  def public_verification_notice
    I18n.t "slack_notifications.timeline_events.verification.public",
      startup_url: @startup_url, startup_product_name: @startup.product_name, event_url: @timeline_event_url,
      event_title: @timeline_event.title, event_description: @timeline_event.description
  end

  def public_needs_improvement_notice
    I18n.t "slack_notifications.timeline_events.needs_improvement.public",
      startup_url: @startup_url, startup_product_name: @startup.product_name, event_url: @timeline_event_url,
      event_title: @timeline_event.title, event_description: @timeline_event.description
  end
end

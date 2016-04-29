class TimelineEventVerificationNotificationJob < ActiveJob::Base
  queue_as :default

  def perform(timeline_event)
    # few common attributes
    @timeline_event = timeline_event
    @startup = @timeline_event.startup
    @startup_url = Rails.application.routes.url_helpers.startup_url(@startup)
    @timeline_event_url = @startup_url + "#event-#{@timeline_event.id}"

    # return if invoked for a pending event - Pending events have no associated notifications, yet
    return if @timeline_event.pending?

    # decide the appropriate channel to ping - private ping for founder events and not accepted ones, general channel for public announcements
    target =  if @timeline_event.founder_event?
      { founder: @timeline_event.founder }
    elsif @timeline_event.not_accepted?
      { founders: @timeline_event.startup&.founders }
    else
      { channel: '#general' }
    end

    # ping appropriate message on slack
    PublicSlackTalk.post_message({ message: slack_notice }.merge(target))
  end

  private

  # form appropriate slack message
  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def slack_notice
    if @timeline_event.verified?
      @timeline_event.founder_event? ? private_verification_notice : public_verification_notice
    elsif @timeline_event.needs_improvement?
      @timeline_event.founder_event? ? private_needs_improvement_notice : public_needs_improvement_notice
    elsif @timeline_event.not_accepted?
      @timeline_event.founder_event? ? private_not_accepted_notice : public_not_accepted_notice
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def private_verification_notice
    I18n.t "slack_notifications.timeline_events.verification.private", event_title: @timeline_event.title, event_url: @timeline_event_url
  end

  def private_needs_improvement_notice
    I18n.t "slack_notifications.timeline_events.needs_improvement.private", event_title: @timeline_event.title, event_url: @timeline_event_url
  end

  def private_not_accepted_notice
    I18n.t "slack_notifications.timeline_events.not_accepted.private", event_title: @timeline_event.title, event_url: @timeline_event_url
  end

  def public_verification_notice
    I18n.t "slack_notifications.timeline_events.verification.public",
      startup_url: @startup_url, startup_product_name: @startup.product_name, event_url: @timeline_event_url,
      event_title: @timeline_event.title, event_description: @timeline_event.description, links_attached_notice: links_attached_notice
  end

  def public_needs_improvement_notice
    I18n.t "slack_notifications.timeline_events.needs_improvement.public",
      startup_url: @startup_url, startup_product_name: @startup.product_name, event_url: @timeline_event_url,
      event_title: @timeline_event.title, event_description: @timeline_event.description, links_attached_notice: links_attached_notice
  end

  # this is not exactly 'public' but to 'all founders'. Using public for consistency in naming
  def public_not_accepted_notice
    I18n.t "slack_notifications.timeline_events.not_accepted.public",
      event_title: @timeline_event.title, event_url: @timeline_event_url, startup_product_name: @startup.product_name
  end

  def links_attached_notice
    return '' unless @timeline_event.public_link?

    notice = "*Public Links attached:*\n"
    @timeline_event.links.each.with_index(1) do |link, index|
      next if link[:private]
      short_url = Shortener::ShortenedUrl.generate(link[:url])
      notice += "#{index}. <https://sv.co/#{short_url.unique_key}|#{link[:title]}>\n"
    end

    notice
  end
end

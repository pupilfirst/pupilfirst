class TimelineEventDecorator < Draper::Decorator
  delegate_all

  def facebook_friendly_url
    Rails.application.routes.url_helpers.timeline_event_show_startup_url(
      id: startup.slug, event_title: title.parameterize, event_id: id
    )
  end
end

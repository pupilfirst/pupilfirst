module WebhookEntries
  class CreateService
    def initialize(school, event_type)
      @school = school
      @event_type = event_type
    end

    def execute(data)
      return if webhook_endpoint.blank?

      return unless @event_type.in? webhook_endpoint.enabled_events

      entry = WebhookEntry.create!(event: @event_type, payload: payload(data), school: @school, webhook_url: webhook_endpoint.webhook_url)
      WebhookEntries::DeliverJob.perform_later(entry)
    end

    private

    def webhook_endpoint
      @webhook_endpoint ||= @school.webhook_endpoint
    end

    def payload(data)
      {
        event: @event_type,
        data: data
      }
    end
  end
end

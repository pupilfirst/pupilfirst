module Discord
  class NotificationJob < ApplicationJob
    rescue_from ActiveJob::DeserializationError do |_exception|
      true # Skip processing if the resource have been deleted.
    end

    def perform(event, resource)
      unless [:topic_created].include?(event)
        raise "Encountered unexpected event #{event}"
      end

      @event = event
      @resource = resource

      return if skip?

      case @event
      when :topic_created
        Discord::CommunityMessageService
          .new(@resource.community)
          .post_topic_created(@resource)
      end
    end

    def skip?
      case @event
      when :topic_created
        @resource.archived?
      end
    end
  end
end

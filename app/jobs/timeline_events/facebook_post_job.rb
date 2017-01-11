module TimelineEvents
  class FacebookPostJob < ApplicationJob
    queue_as :default

    def perform(timeline_event)
      TimelineEvents::FacebookPostService.new(timeline_event).post
    end
  end
end

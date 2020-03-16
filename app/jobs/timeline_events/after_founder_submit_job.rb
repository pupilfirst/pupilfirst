module TimelineEvents
  class AfterFounderSubmitJob < ApplicationJob
    queue_as :default

    def perform(timeline_event)
      MarkAsImprovedTargetService.new(timeline_event).execute
    end
  end
end

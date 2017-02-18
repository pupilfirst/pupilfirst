module TimelineEvents
  class AfterFounderSubmitJob < ApplicationJob
    queue_as :default

    def perform(timeline_event)
      MarkAsImprovedTaskService.new(timeline_event).execute
    end
  end
end

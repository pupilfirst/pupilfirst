module TimelineEvents
  # This service can be used to undo the effects of verifying a timeline event.
  class UndoVerificationService
    def initialize(timeline_event)
      @timeline_event = timeline_event
    end

    def execute
      # TODO: Remove karma points.
      # TODO: Recompute timeline updated on.
      # TODO: Fix startup level if event was of iteration ending type.
      # TODO: Unlink / remove founder resume if it was a resume submission.
      # TODO: Update timeline event status.
    end
  end
end

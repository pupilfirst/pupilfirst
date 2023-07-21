module TimelineEvents
  class AfterMarkingAsCompleteJob < ApplicationJob
    queue_as :default

    def perform(submission)
      # Refuse to process submissions from reviewed targets.
      return if submission.evaluation_criteria.exists?

      if TimelineEvents::WasLastTargetService.new(submission).was_last_target?
        Students::AfterCourseCompletionService.new(submission.students.first).execute
      end
    end
  end
end

module TimelineEvents
  class AfterGradingJob < ApplicationJob
    queue_as :default

    def perform(submission)
      # Only process submissions from reviewed submissions.
      return unless submission.reviewed?

      if submission.passed_at.blank?
        Coaches::RepeatRejectionsAlertService.new(submission).execute
      end

      if TimelineEvents::WasLastTargetService.new(submission).was_last_target?
        Students::AfterCourseCompletionService.new(submission.students.first)
          .execute
      end
    end
  end
end

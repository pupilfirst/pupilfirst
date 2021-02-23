module TimelineEvents
  class AfterGradingJob < ApplicationJob
    queue_as :default

    def perform(submission_id)
      submission = TimelineEvent.find(submission_id)
      # Only process submissions from reviewed submissions.
      return unless submission.reviewed?

      if TimelineEvents::WasLastTargetService.new(submission).was_last_target?
        Startups::IssueCertificateService.new(submission.founders.first.startup).execute
      end
    end
  end
end

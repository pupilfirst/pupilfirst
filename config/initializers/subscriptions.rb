ActiveSupport::Notifications.subscribe("submission_graded.pupilfirst") do |_, _, _, _, payload|
  submission = TimelineEvent.find(payload.fetch(:resource_id))
  TimelineEvents::AfterGradingJob.perform_later(submission)
end

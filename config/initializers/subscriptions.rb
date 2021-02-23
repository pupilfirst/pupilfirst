ActiveSupport::Notifications.subscribe("submission_graded.pupilfirst") do |_, _, _, _, payload|
  TimelineEvents::AfterGradingJob.perform_later(payload.fetch(:resource_id))
end

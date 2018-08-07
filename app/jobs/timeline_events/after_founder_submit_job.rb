module TimelineEvents
  class AfterFounderSubmitJob < ApplicationJob
    queue_as :default

    def perform(timeline_event)
      notify_coach_about(timeline_event) if timeline_event.startup.faculty.present?
      MarkAsImprovedTargetService.new(timeline_event).execute
    end

    private

    def notify_coach_about(timeline_event)
      FacultyMailer.student_submission_notification(timeline_event).deliver_now
    end
  end
end

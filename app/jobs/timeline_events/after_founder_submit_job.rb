module TimelineEvents
  class AfterFounderSubmitJob < ApplicationJob
    queue_as :default

    def perform(timeline_event)
      notify_coach_about(timeline_event) if timeline_event.startup.faculty.present?
      MarkAsImprovedTargetService.new(timeline_event).execute
    end

    private

    def notify_coach_about(timeline_event)
      timeline_event.startup.faculty.active.each do |faculty|
        FacultyMailer.student_submission_notification(timeline_event, faculty).deliver_now
      end
    end
  end
end

module TimelineEvents
  class AfterFounderSubmitJob < ApplicationJob
    queue_as :default

    def perform(timeline_event)
      notify_coach_about(timeline_event) if timeline_event.founders.first.faculty.present?
      MarkAsImprovedTargetService.new(timeline_event).execute
    end

    private

    def notify_coach_about(timeline_event)
      timeline_event.founders.first.faculty.where(notify_for_submission: true).each do |faculty|
        FacultyMailer.student_submission_notification(timeline_event, faculty).deliver_now
      end
    end
  end
end

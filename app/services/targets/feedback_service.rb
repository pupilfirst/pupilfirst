module Targets
  class FeedbackService
    def initialize(target, founder)
      @target = target
      @founder = founder
    end

    def latest_feedback_details
      return nil if latest_feedback.blank?

      {
        facultyName: faculty.name,
        feedback: latest_feedback.feedback,
        facultySlackUsername: faculty.slack_username,
        facultyImageUrl: faculty.user.image_or_avatar_url
      }
    end

    private

    def latest_feedback
      @latest_feedback ||= linked_event&.startup_feedback&.order('created_at')&.last
    end

    def faculty
      @faculty ||= latest_feedback.faculty
    end

    def linked_event
      @target.latest_linked_event(@founder)
    end
  end
end

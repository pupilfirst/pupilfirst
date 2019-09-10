module Types
  class ReviewSubmissionDetailsType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, String, null: false
    field :feedback_sent, Boolean, null: false
    field :failed, Boolean, null: false
    field :description, String, null: false

    # def grading
    #   TimelineEventGrade.where(timeline_event_id: submissions.pluck(:id)).map do |submission_grading|
    #     {
    #       submission_id: submission_grading.timeline_event_id,
    #       evaluation_criterion_id: submission_grading.evaluation_criterion_id,
    #       grade: submission_grading.grade
    #     }
    #   end
    # end

    # def feedback_for_submissions
    #   StartupFeedback.where(timeline_event_id: submissions.pluck(:id)).map do |feedback|
    #     {
    #       id: feedback.id,
    #       coach_id: feedback.faculty_id,
    #       submission_id: feedback.timeline_event_id,
    #       feedback: feedback.feedback
    #     }
    #   end
    # end

    # def attachments_for_submissions
    #   submissions.map do |submission|
    #     files = submission.timeline_event_files.with_attached_file.map do |file|
    #       {
    #         id: file.id,
    #         submission_id: submission.id,
    #         submission_type: "file",
    #         title: file.file.filename,
    #         url: url_helpers.download_timeline_event_file_path(file)
    #       }
    #     end
    #
    #     links = submission.links.map do |link|
    #       {
    #         submission_id: submission.id,
    #         submission_type: "link",
    #         url: link
    #       }
    #     end
    #
    #     files + links
    #   end.flatten
    # end

    def feedback_sent
      object.startup_feedback.present?
    end

    def failed
      object.passed_at.nil?
    end
  end
end

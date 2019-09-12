module Types
  class ReviewSubmissionDetailsType < Types::BaseObject
    field :id, ID, null: false
    field :created_at, String, null: false
    field :passed_at, String, null: true
    field :evaluator_id, ID, null: true
    field :description, String, null: false
    field :feedback, [Types::SubmissionFeedbackType], null: false
    field :grades, [Types::SubmissionGradeType], null: false
    field :attachments, [Types::SubmissionAttachmentType], null: false

    def grades
      object.timeline_event_grades.map do |submission_grading|
        {
          id: submission_grading.id,
          evaluation_criterion_id: submission_grading.evaluation_criterion_id,
          grade: submission_grading.grade
        }
      end
    end

    def feedback
      object.startup_feedback.map do |feedback|
        {
          id: feedback.id,
          coach_id: feedback.faculty_id,
          created_at: feedback.created_at,
          value: feedback.feedback
        }
      end
    end

    def attachments
      files = object.timeline_event_files.with_attached_file.map do |file|
        {
          title: file.file.filename,
          url: Rails.application.routes.url_helpers.download_timeline_event_file_path(file)
        }
      end

      links = object.links.map do |link|
        {
          title: nil,
          url: link
        }
      end

      files + links
    end
  end
end

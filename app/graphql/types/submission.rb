module Types
  class Submission < Types::BaseObject
    field :id, ID, null: false
    field :description, String, null: false
    field :created_at, String, null: false
    field :passed_at, String, null: true
    field :evaluator_name, String, null: true
    field :feedback, [Types::SubmissionFeedbackType], null: false
    field :grades, [Types::GradeType], null: false
    field :attachments, [Types::SubmissionAttachmentType], null: false
    # field :evaluation_criteria, [Types::EvaluationCriteria], null: false

    def evaluator_name
      object.evaluator&.name
    end

    def grades
      object.timeline_event_grades.map do |submission_grading|
        {
          evaluation_criterion_id: submission_grading.evaluation_criterion_id,
          grade: submission_grading.grade
        }
      end
    end

    def evaluation_criteria
      object.evaluation_criteria.map do |criteria|
        {
          id: criteria.id,
          name: criteria.name
        }
      end
    end

    def feedback
      object.startup_feedback.map do |feedback|
        {
          id: feedback.id,
          created_at: feedback.created_at,
          value: feedback.feedback,
          coach_name: feedback.faculty.user.name,
          coach_avatar_url: feedback.faculty.user.image_or_avatar_url,
          coach_title: feedback.faculty.user.title
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

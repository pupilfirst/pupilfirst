module Types
  class SubmissionType < Types::BaseObject
    connection_type_class Types::PupilfirstConnection

    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :evaluated_at, GraphQL::Types::ISO8601DateTime, null: true
    field :passed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :evaluator_name, String, null: true
    field :feedback, [Types::SubmissionFeedbackType], null: false
    field :grades, [Types::GradeType], null: false
    field :files, [Types::SubmissionFileType], null: false
    field :checklist, GraphQL::Types::JSON, null: false
    field :title, String, null: false
    field :level_id, ID, null: false
    field :target_id, ID, null: false
    field :user_names, String, null: false
    field :feedback_sent, Boolean, null: false
    field :coach_ids, [String], null: false
    field :team_name, String, null: true

    def title
      object.target.title
    end

    def level_id
      object.target.target_group.level_id
    end

    def user_names
      object.founders.map do |founder|
        founder.user.name
      end.join(', ')
    end

    def feedback_sent
      object.startup_feedback.present?
    end

    def coach_ids
      team_ids = object.founders.map(&:startup_id).uniq
      FacultyStartupEnrollment.where(startup_id: team_ids).pluck(:faculty_id)
    end

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

    def feedback
      object.startup_feedback
    end

    def files
      object.timeline_event_files.with_attached_file.map do |file|
        {
          id: file.id,
          title: file.file.filename,
          url: Rails.application.routes.url_helpers.download_timeline_event_file_path(file)
        }
      end
    end

    def students_have_same_team
      object.founders.distinct(:startup_id).pluck(:startup_id).one?
    end

    def team_name
      if object.team_submission? && students_have_same_team && object.timeline_event_owners.count > 1
        object.founders.first.startup.name
      end
    end
  end
end

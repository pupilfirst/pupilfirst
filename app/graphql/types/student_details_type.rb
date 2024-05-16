module Types
  class StudentDetailsType < Types::BaseObject
    field :email, String, null: false
    field :evaluation_criteria, [Types::EvaluationCriterionType], null: false
    field :assignments_completed, Integer, null: false
    field :assignments_pending_review, Integer, null: false
    field :total_assignments, Integer, null: false
    field :total_page_reads, Integer, null: false
    field :total_targets, Integer, null: false
    field :quiz_scores, [String], null: false
    field :average_grades, [Types::EvaluationCriterionAverageType], null: false
    field :team, Types::TeamType, null: true
    field :student, Types::StudentType, null: false
    field :milestones_completion_status,
          [Types::MilestonesCompletionStatusType],
          null: false
    field :can_modify_coach_notes, Boolean, null: false
  end
end

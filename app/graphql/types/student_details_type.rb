module Types
  class StudentDetailsType < Types::BaseObject
    field :email, String, null: false
    field :evaluation_criteria, [Types::EvaluationCriterionType], null: false
    field :targets_completed, Integer, null: false
    field :targets_pending_review, Integer, null: false
    field :total_targets, Integer, null: false
    field :quiz_scores, [String], null: false
    field :average_grades, [Types::EvaluationCriterionAverageType], null: false
    field :team, Types::TeamType, null: true
    field :student, Types::StudentType, null: false
    field :milestone_targets_completion_status,
          [Types::MilestoneTargetsCompletionStatusType],
          null: false
    field :can_modify_coach_notes, Boolean, null: false
  end
end

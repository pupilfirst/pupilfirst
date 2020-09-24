module Types
  class StudentDetailsType < Types::BaseObject
    field :email, String, null: false
    field :evaluation_criteria, [Types::EvaluationCriterionType], null: false
    field :targets_completed, Integer, null: false
    field :targets_pending_review, Integer, null: false
    field :total_targets, Integer, null: false
    field :quiz_scores, [String], null: false
    field :average_grades, [Types::EvaluationCriterionAverageType], null: false
    field :completed_level_ids, [ID], null: false
    field :team, Types::TeamType, null: false
  end
end

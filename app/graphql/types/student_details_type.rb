module Types
  class StudentDetailsType < Types::BaseObject
    field :name, String, null: false
    field :title, String, null: false
    field :email, String, null: false
    field :phone, String, null: true
    field :coach_notes, [Types::CoachNoteType], null: false
    field :level_id, ID, null: false
    field :social_links, [String], null: false
    field :evaluation_criteria, [Types::EvaluationCriteriaType], null: false
    field :targets_completed, Integer, null: false
    field :total_targets, Integer, null: false
    field :quiz_scores, [String], null: false
    field :average_grades, [Types::EvaluationCriterionAverageType], null: false
  end
end

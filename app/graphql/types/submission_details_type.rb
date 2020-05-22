module Types
  class SubmissionDetailsType < Types::BaseObject
    field :submissions, [Types::SubmissionType], null: false
    field :target_id, ID, null: false
    field :target_title, String, null: false
    field :students, [Types::StudentMiniType], null: false
    field :level_number, String, null: false
    field :team_name, String, null: true
    field :level_id, ID, null: false
    field :evaluation_criteria, [Types::EvaluationCriterionType], null: false
    field :review_checklist, [Types::ReviewChecklistType], null: false
    field :target_evaluation_criteria_ids, [ID], null: false
    field :inactive_students, Boolean, null: false
    field :coach_ids, [ID], null: false
  end
end

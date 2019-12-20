module Types
  class SubmissionDetailsType < Types::BaseObject
    field :submissions, [Types::SubmissionType], null: false
    field :target_id, ID, null: false
    field :target_title, String, null: false
    field :user_names, String, null: false
    field :level_number, String, null: false
    field :level_id, ID, null: false
    field :evaluation_criteria, [Types::StudentEvaluationCriterionType], null: false
    field :review_checklist, [Types::ReviewChecklistType], null: false
    field :target_evaluation_criteria_ids, [ID], null: false
  end
end

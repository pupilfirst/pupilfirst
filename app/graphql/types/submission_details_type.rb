module Types
  class SubmissionDetailsType < Types::BaseObject
    field :all_submissions, [Types::SubmissionInfoType], null: false
    field :submission, Types::SubmissionType, null: false
    field :target_id, ID, null: false
    field :course_id, ID, null: false
    field :target_title, String, null: false
    field :students, [Types::StudentMiniType], null: false
    field :level_number, String, null: false
    field :team_name, String, null: true
    field :level_id, ID, null: false
    field :evaluation_criteria, [Types::EvaluationCriterionType], null: false
    field :review_checklist, [Types::ReviewChecklistType], null: false
    field :target_evaluation_criteria_ids, [ID], null: false
    field :inactive_students, Boolean, null: false
    field :coaches, [Types::UserProxyType], null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

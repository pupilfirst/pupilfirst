module Types
  class StudentDetailsType < Types::BaseObject
    field :title, String, null: false
    field :email, String, null: false
    field :phone, String, null: true
    field :coach_notes, [Types::CoachNoteType], null: true
    field :submissions, [Types::StudentSubmissionType], null: true
    field :level_id, ID, null: false
    field :social_links, [String], null: true
    field :evaluation_criteria, [Types::EvaluationCriteriaType], null: false
    field :grades, [Types::GradeType], null: false
  end
end

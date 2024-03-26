module Types
  class AssignmentDetailsType < Types::BaseObject
    field :role, String, null: false
    field :evaluation_criteria, [ID], null: false
    field :prerequisite_targets, [ID], null: false
    field :quiz, [AssignmentQuizType], null: false
    field :completion_instructions, String, null: true
    field :checklist, GraphQL::Types::JSON, null: false
    field :milestone, Boolean, null: false
    field :archived, Boolean, null: false
    field :discussion, Boolean, null: false
    field :allow_anonymous, Boolean, null: false
  end
end

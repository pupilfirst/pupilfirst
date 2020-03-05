module Types
  class TargetDetailsType < Types::BaseObject
    field :title, String, null: false
    field :role, String, null: false
    field :target_group_id, ID, null: false
    field :evaluation_criteria, [ID], null: false
    field :prerequisite_targets, [ID], null: false
    field :quiz, [TargetQuizType], null: false
    field :completion_instructions, String, null: true
    field :link_to_complete, String, null: true
    field :visibility, String, null: false
    field :checklist, GraphQL::Types::JSON, null: false
  end
end

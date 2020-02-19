module Mutations
  class UpdateTarget < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :title, String, required: true
    argument :role, String, required: true
    argument :target_group_id, ID, required: true
    argument :evaluation_criteria, [ID], required: true
    argument :prerequisite_targets, [ID], required: true
    argument :quiz, [Types::TargetQuizInputType], required: true
    argument :completion_instructions, String, required: false
    argument :link_to_complete, String, required: false
    argument :checklist, GraphQL::Types::JSON, required: true
    argument :visibility, String, required: true

    description "Update a target"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateTargetMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, 'Done!', 'Target updated successfully!')
        mutator.update
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

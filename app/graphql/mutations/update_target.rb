module Mutations
  class UpdateTarget < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :title, String, required: true
    argument :role, String, required: true
    argument :target_group_id, ID, required: true
    argument :evaluation_criteria, [ID], required: true
    argument :prerequisite_targets, [ID], required: true
    argument :quiz, [Types::TargetQuizType], required: true
    argument :completion_instructions, String, required: true
    argument :link_to_complete, String, required: true
    argument :visibility, String, required: true

    description "Update a target"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateTargetMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, 'Done!', 'Evaluation criterion updated successfully!')
        mutator.update
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

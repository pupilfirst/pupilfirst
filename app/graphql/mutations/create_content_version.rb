module Mutations
  class CreateContentVersion < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true

    description "Create a content version"

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

module Mutations
  class CompleteTarget < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true

    description "Mark a un-reviewed target as complete"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CompleteTargetMutator.new(params, context)

      if mutator.valid?
        mutator.complete target
        { success: true }
      else
        { success: false }
      end
    end
  end
end

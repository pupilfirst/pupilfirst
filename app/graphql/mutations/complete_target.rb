module Mutations
  class CompleteTarget < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true

    description "Mark a un-reviewed target as complete"

    field :errors, [String], null: false

    def resolve(params)
      mutator = CompleteTargetMutator.new(params, context)

      mutator.complete target if mutator.valid?

      { errors: mutator.error_codes }
    end
  end
end

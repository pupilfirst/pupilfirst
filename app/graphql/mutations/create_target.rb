module Mutations
  class CreateTarget < GraphQL::Schema::Mutation
    argument :title, String, required: true
    argument :target_group_id, String, required: true

    description "Create a new target."

    field :target_id, ID, null: true
    field :errors, [Types::CreateTargetErrors], null: true

    def resolve(params)
      mutator = CreateTargetMutator.new(params, context)

      if mutator.valid?
        { target_id: mutator.create_target.id, errors: [] }
      else
        { target_id: nil, errors: mutator.error_codes }
      end
    end
  end
end

module Mutations
  class CreateTarget < GraphQL::Schema::Mutation
    argument :title, String, required: true
    argument :target_group_id, String, required: true

    description "Create a new target."

    field :target, Types::CreateTargetType, null: true

    def resolve(params)
      mutator = CreateTargetMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, "Done!", "Target created successfully.")
        { target: mutator.create_target, errors: nil }
      else
        mutator.notify_errors
        { target: nil, errors: mutator.error_messages }
      end
    end
  end
end

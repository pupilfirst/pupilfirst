module Mutations
  class UpdateTarget < GraphQL::Schema::Mutation
    argument :title, String, required: true
    argument :role, String, required: true
    argument :target_action_type, String, required: true

    description "Update a target."

    field :target, Types::TargetType, null: false

    def resolve(params)
      mutator = UpdateTargetMutator.new(params, context)

      if mutator.valid?
        { target: mutator.update_target, errors: [] }
      else
        { target: nil, errors: mutator.error_codes }
      end
    end
  end
end

module Mutations
  class CreateTargetVersion < GraphQL::Schema::Mutation
    argument :target_version_id, ID, required: true

    description "Update a target"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreateTargetVersionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, 'Done!', 'A new version has been created.')
        mutator.create_target_version
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

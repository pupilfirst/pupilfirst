module Mutations
  class RestoreContentVersion < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :version_on, Types::DateType, required: true

    description "Restores target content to a selected version"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = RestoreContentVersionMutator.new(context, params)

      if mutator.valid?
        mutator.notify(:success, "Done!", "Version restored successfully.")
        mutator.restore
        { success: true }
      else
        mutator.notify_errors
        { success: false, errors: mutator.error_messages }
      end
    end
  end
end

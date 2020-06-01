module Mutations
  class InitiateAccountDeletion < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :password, String, required: true

    description "Delete user account"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = InitiateAccountDeletionMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, 'User Deletion Initiated', 'Check your inbox for further steps!')
        mutator.execute
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end

module Mutations
  class DeleteAccount < GraphQL::Schema::Mutation
    argument :token, String, required: true

    description "Delete user account permanently"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteAccountMutator.new(context, params)

      success = if mutator.valid?
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

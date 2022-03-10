module Mutations
  class InitiateAccountDeletion < GraphQL::Schema::Mutation
    argument :email, String, required: true

    description "Delete user account"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = InitiateAccountDeletionMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, I18n.t("notes.deletion_init"), I18n.t("notes.check_inbox"))
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

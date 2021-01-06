module Mutations
  class DeleteWebpushSubscription < GraphQL::Schema::Mutation
    description "Delete web push subscription"

    field :success, Boolean, null: false

    def resolve
      mutator = DeleteWebpushSubscriptionMutator.new(context, {})
      success = if mutator.valid?
        mutator.delete_subscription
        true
      else
        mutator.notify_errors
        false
      end
      { success: success }
    end
  end
end

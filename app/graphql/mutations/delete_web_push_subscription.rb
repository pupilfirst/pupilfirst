module Mutations
  class DeleteWebPushSubscription < GraphQL::Schema::Mutation
    description "Delete web push subscription"

    field :success, Boolean, null: false

    def resolve
      mutator = DeleteWebPushSubscriptionMutator.new(context, {})
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

module Mutations
  class CreateWebPushSubscription < GraphQL::Schema::Mutation
    argument :endpoint, String, required: true
    argument :p256dh, String, required: true
    argument :auth, String, required: true

    description "Create web push subscription"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreateWebPushSubscriptionMutator.new(context, params)

      if mutator.valid?
        mutator.create_subscription
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

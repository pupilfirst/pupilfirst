module Mutations
  class DeleteTopicSubscription < GraphQL::Schema::Mutation
    argument :topic_id, ID, required: true

    description "Unsubscribe from a topic"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteTopicSubscriptionMutator.new(context, params)

      if mutator.valid?
        mutator.delete_subscription
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

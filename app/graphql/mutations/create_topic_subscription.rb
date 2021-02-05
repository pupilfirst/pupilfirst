module Mutations
  class CreateTopicSubscription < GraphQL::Schema::Mutation
    argument :topic_id, ID, required: true

    description "Create a topic subscription."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreateTopicSubscriptionMutator.new(context, params)

      if mutator.valid?
        mutator.subscribe
        mutator.notify(:success, I18n.t('shared.done_exclamation'), I18n.t('mutations.create_topic_subscription.success_notification'))
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

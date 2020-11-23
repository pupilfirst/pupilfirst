module Mutations
  class UnlockTopic < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Unlock a topic in community."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UnlockTopicMutator.new(context, params)

      if mutator.valid?
        mutator.unlock_topic
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

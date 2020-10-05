module Mutations
  class CreateTopic < GraphQL::Schema::Mutation
    argument :title, String, required: true
    argument :body, String, required: true
    argument :community_id, ID, required: true
    argument :target_id, ID, required: false
    argument :topic_category_id, ID, required: false

    description 'Create a new topic of discussion in a community'

    field :topic_id, ID, null: true

    def resolve(params)
      mutator = CreateTopicMutator.new(context, params)

      if mutator.valid?
        topic = mutator.create_topic
        { topic_id: topic.id }
      else
        mutator.notify_errors
        { topic_id: nil }
      end
    end
  end
end

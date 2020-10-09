module Mutations
  class CreateTopicCategory < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :community_id, ID, required: true

    description "Create a category in community."

    field :id, ID, null: true

    def resolve(params)
      mutator = CreateTopicCategoryMutator.new(context, params)

      if mutator.valid?
        category = mutator.create_topic_category
        { id: category.id }
      else
        mutator.notify_errors
        { id: nil }
      end
    end
  end
end

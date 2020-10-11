module Mutations
  class DeleteTopicCategory < GraphQL::Schema::Mutation
    argument :id, ID, required: true

    description "Destroy a category in community."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = DeleteTopicCategoryMutator.new(context, params)

      if mutator.valid?
        mutator.delete_topic_category
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

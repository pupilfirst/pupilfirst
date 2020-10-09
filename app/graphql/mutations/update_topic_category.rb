module Mutations
  class UpdateTopicCategory < GraphQL::Schema::Mutation
    argument :name, String, required: true
    argument :id, ID, required: true

    description "Update a category in community."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateTopicCategoryMutator.new(context, params)

      if mutator.valid?
        mutator.update_topic_category
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

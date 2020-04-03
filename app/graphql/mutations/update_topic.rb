module Mutations
  class UpdateTopic < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :title, String, required: true

    description "Update a topic"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateTopicMutator.new(context, params)

      success = if mutator.valid?
        mutator.update_topic
        true
      else
        false
      end

      { success: success }
    end
  end
end

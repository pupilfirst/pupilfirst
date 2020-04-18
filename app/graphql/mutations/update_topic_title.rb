module Mutations
  class UpdateTopicTitle < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :title, String, required: true

    description "Update title of topic in community"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateTopicTitleMutator.new(context, params)

      success = if mutator.valid?
        mutator.update_topic_title
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end

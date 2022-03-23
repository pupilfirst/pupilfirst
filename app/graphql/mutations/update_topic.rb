module Mutations
  class UpdateTopic < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :title, String, required: true
    argument :topic_category_id, ID, required: false

    description "Update a topic"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = UpdateTopicMutator.new(context, params)

      success = if mutator.valid?
        mutator.notify(:success, I18n.t("shared.notifications.done"), I18n.t("mutations.update_topic.topic_updated_notification"))
        mutator.update_topic
        true
      else
        mutator.notify_errors
        false
      end

      { success: success }
    end
  end
end

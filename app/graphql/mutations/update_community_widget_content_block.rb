module Mutations
  class UpdateCommunityWidgetContentBlock < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :kind, String, required: true
    argument :slug, String, required: true

    description "Updates the settings of community widget block."

    field :content_block, Types::ContentBlockType, null: true

    def resolve(params)
      mutator = UpdateCommunityWidgetContentBlockMutator.new(context, params)

      content_block = if mutator.valid?
        mutator.update_community_widget_content_block
      else
        mutator.notify_errors
        nil
      end

      { content_block: content_block }
    end
  end
end

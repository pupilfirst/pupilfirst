module Mutations
  class CreateCommunityWidgetContentBlock < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :above_content_block_id, ID, required: false
    argument :kind, String, required: true
    argument :slug, String, required: true

    description "Creates a community widget content block."

    field :content_block, Types::ContentBlockType, null: true

    def resolve(params)
      mutator = CreateCommunityWidgetContentBlockMutator.new(context, params)

      content_block = if mutator.valid?
        mutator.create_community_widget_content_block
      else
        mutator.notify_errors
        nil
      end

      { content_block: content_block }
    end
  end
end

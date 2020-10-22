module Mutations
  class CreateEmbedContentBlock < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :above_content_block_id, ID, required: false
    argument :url, String, required: true
    argument :request_source, Types::EmbedRequestSource, required: true

    description "Creates an embed content block."

    field :content_block, Types::ContentBlockType, null: true

    def resolve(params)
      mutator = CreateEmbedContentBlockMutator.new(context, params)

      content_block = if mutator.valid?
        mutator.create_embed_content_block
      else
        mutator.notify_errors
        nil
      end

      { content_block: content_block }
    end
  end
end

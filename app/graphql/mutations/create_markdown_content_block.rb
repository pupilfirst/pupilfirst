module Mutations
  class CreateMarkdownContentBlock < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :above_content_block_id, ID, required: false

    description "Creates a markdown content block."

    field :content_block, Types::ContentBlockType, null: true

    def resolve(params)
      mutator = CreateMarkdownContentBlockMutator.new(context, params)

      content_block = if mutator.valid?
        mutator.create_markdown_content_block
      else
        mutator.notify_errors
        nil
      end

      { content_block: content_block }
    end
  end
end

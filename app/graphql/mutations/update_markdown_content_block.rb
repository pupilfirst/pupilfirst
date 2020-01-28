module Mutations
  class UpdateMarkdownContentBlock < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :markdown, String, required: false

    description "Updates the markdown content of a markdown block."

    field :content_block, Types::ContentBlockType, null: true

    def resolve(params)
      mutator = UpdateMarkdownContentBlockMutator.new(context, params)

      content_block = if mutator.valid?
        mutator.update_markdown_content_block
      else
        mutator.notify_errors
        nil
      end

      { content_block: content_block }
    end
  end
end

module Mutations
  class CreateMarkdownContentBlock < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :above_content_block_id, ID, required: false

    description "Deletes a target content block."

    field :success, Boolean, null: false

    def resolve(params)
      mutator = CreateMarkdownContentBlockMutator.new(context, params)

      if mutator.valid?
        mutator.create_markdown_content_block
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

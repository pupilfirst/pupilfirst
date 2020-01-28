module Mutations
  class UpdateFileContentBlock < GraphQL::Schema::Mutation
    argument :id, ID, required: true
    argument :title, String, required: false

    description "Updates the title of a file block."

    field :content_block, Types::ContentBlockType, null: true

    def resolve(params)
      mutator = UpdateFileContentBlockMutator.new(context, params)

      content_block = if mutator.valid?
        mutator.update_file_content_block
      else
        mutator.notify_errors
        nil
      end

      { content_block: content_block }
    end
  end
end

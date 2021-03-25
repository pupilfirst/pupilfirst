module Mutations
  class InsertContentBlock < GraphQL::Schema::Mutation
    argument :target_id, ID, required: true
    argument :above_content_block_id, ID, required: false
    argument :block_type, String, required: true

    description "Inserts a predefined content block."

    field :content_block, Types::ContentBlockType, null: true

    def resolve(params)
      mutator = InsertContentBlockMutator.new(context, params)

      content_block = if mutator.valid?
        mutator.insert_content_block
      else
        mutator.notify_errors
        nil
      end

      { content_block: content_block }
    end
  end
end

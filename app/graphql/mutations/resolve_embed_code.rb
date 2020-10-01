module Mutations
  class ResolveEmbedCode < GraphQL::Schema::Mutation
    argument :content_block_id, ID, required: true

    description "Resolve Embed COde"

    field :success, Boolean, null: false

    def resolve(params)
      mutator = ResolveEmbedCodeMutator.new(context, params)

      if mutator.valid?
        mutator.resolve
        { success: true }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

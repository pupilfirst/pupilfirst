module Mutations
  class ResolveEmbedCode < GraphQL::Schema::Mutation
    argument :content_block_id, ID, required: true

    description "Resolve Embed Code"

    field :embed_code, String, null: true

    def resolve(params)
      mutator = ResolveEmbedCodeMutator.new(context, params)

      if mutator.valid?
        { embed_code: mutator.resolve }
      else
        mutator.notify_errors
        { success: false }
      end
    end
  end
end

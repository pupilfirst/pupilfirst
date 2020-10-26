module Mutations
  class ResolveEmbedCode < GraphQL::Schema::Mutation
    argument :content_block_id, ID, required: true

    description "Resolve Embed Code for a given content block"

    field :embed_code, String, null: true

    def resolve(params)
      mutator = ResolveEmbedCodeMutator.new(context, params)

      embed_code = if mutator.valid?
        mutator.resolve
      else
        mutator.notify_errors
        nil
      end

      { embed_code: embed_code }
    end
  end
end

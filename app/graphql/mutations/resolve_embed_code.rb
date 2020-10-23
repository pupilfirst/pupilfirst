module Mutations
  class ResolveEmbedCode < GraphQL::Schema::Mutation
    argument :content_block_id, ID, required: true

    description "Resolve Embed Code for a given content block"

    field :embed_code, String, null: true

    def resolve(params)
      mutator = ResolveEmbedCodeMutator.new(context, params)
      embed_code = mutator.valid? ? mutator.resolve : nil
      mutator.notify_errors if embed_code.blank?
      { embed_code: embed_code }
    end
  end
end

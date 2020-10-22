module Types
  class EmbedBlockType < Types::BaseObject
    field :url, String, null: false
    field :embed_code, String, null: true
    field :request_source, Types::EmbedRequestSource, null: false
    field :last_resolved_at, String, null: true
  end
end

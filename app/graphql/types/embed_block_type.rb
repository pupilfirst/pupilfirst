module Types
  class EmbedBlockType < Types::BaseObject
    field :url, String, null: false
    field :embed_code, String, null: true
    field :requestSource, String, null: true
    field :lastResolvedAt, String, null: true
  end
end

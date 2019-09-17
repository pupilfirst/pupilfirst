module Types
  class EmbedBlockType < Types::BaseObject
    field :url, String, null: false
    field :embed_code, String, null: false
  end
end

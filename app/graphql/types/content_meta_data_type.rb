module Types
  class ContentMetaDataType < Types::BaseObject
    field :markdown, String, null: true
    field :title, String, null: true
    field :url, String, null: true
    field :embed_code, String, null: true
    field :caption, String, null: true
  end
end

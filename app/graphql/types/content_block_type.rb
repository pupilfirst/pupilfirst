module Types
  class ContentBlockType < Types::BaseObject
    field :id, ID, null: false
    field :block_type, String, null: false
    field :sort_index, Integer, null: false
    field :content, Types::ContentType, null: false

    def content
      object.slice(:block_type, :url, :filename).merge(object[:content])
    end
  end
end

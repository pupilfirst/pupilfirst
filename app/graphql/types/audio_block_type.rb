module Types
    class AudioBlockType < Types::BaseObject
      field :title, String, null: false
      field :url, String, null: false
      field :filename, String, null: false
    end
end
module Types
  class ImageType < Types::BaseObject
    field :url, String, null: false
    field :filename, String, null: false
  end
end

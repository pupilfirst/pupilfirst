module Types
  class ContentFileAttachmentType < Types::BaseObject
    field :url, String, null: false
    field :name, String, null: false
  end
end

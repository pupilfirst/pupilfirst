module Types
  class SchoolLink < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :url, String, null: false
  end
end

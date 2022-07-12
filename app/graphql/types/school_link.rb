module Types
  class SchoolLink < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: true
    field :url, String, null: false
    field :kind, String, null: false
    field :sort_index, Integer, null: false
  end
end
